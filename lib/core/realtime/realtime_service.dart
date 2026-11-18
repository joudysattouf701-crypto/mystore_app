import 'dart:async';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'order_events.dart';

// اشتراك واحد بحدث: عند إغلاق الشاشة نستدعي cancel حتى لا يبقى اشتراك شغال بالخلفية
class RealtimeSubscription {
  final VoidCallback _onCancel;
  bool _cancelled = false;

  RealtimeSubscription._(this._onCancel);

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _onCancel();
  }
}

// اتصال WebSocket واحد للتطبيق كله مع سيرفر Reverb (بروتوكول Pusher).
// - يُفتح عند أول اشتراك ويُغلق عند إلغاء آخر اشتراك أو عند تسجيل الخروج
// - القنوات كلها خاصة: قبل الاشتراك تسأل المكتبة الـ backend عبر
//   POST /broadcasting/auth ومعها JWT، والـ backend يرد 403 إن لم يكن مسموحاً
// - عند رجوع الاتصال بعد انقطاع تصدر onReconnected لتعيد الشاشات الـ GET
class RealtimeService {
  RealtimeService._();
  static final RealtimeService instance = RealtimeService._();

  PusherChannelsClient? _client;
  StreamSubscription<void>? _connectionSub;
  int _connectionCount = 0;

  final Map<String, _ChannelEntry> _channels = {};
  final StreamController<void> _reconnected = StreamController.broadcast();

  // الأحداث التي قد تفوت وقت الانقطاع لا تُعاد، فالشاشة تجلب البيانات من جديد
  Stream<void> get onReconnected => _reconnected.stream;

  // الزبون: تغيير حالة أي طلب من طلباته (قناة private-user.{id}).
  // القناة تحمل أحداث كل طلبات المستخدم، فالفلترة بـ order_id على الشاشة
  RealtimeSubscription watchStatusChanged(
    int userId,
    void Function(OrderStatusChangedEvent event) onEvent,
  ) {
    return _watch(
      RealtimeConfig.userChannel(userId),
      RealtimeConfig.orderStatusChangedEvent,
      (data) => onEvent(OrderStatusChangedEvent.fromJson(data)),
    );
  }

  RealtimeSubscription _watch(
    String channelName,
    String eventName,
    void Function(Map<String, dynamic> data) handler,
  ) {
    final PusherChannelsClient client = _ensureClient();

    final _ChannelEntry entry = _channels.putIfAbsent(
      channelName,
      () => _ChannelEntry(
        client.privateChannel(
          channelName,
          authorizationDelegate: _JwtAuthorizationDelegate(),
        ),
      ),
    );
    entry.refs++;

    // TODO(debug): لوغات تشخيص مؤقتة، تُحذف بعد حل المشكلة
    if (entry.refs == 1) {
      entry.channel.whenSubscriptionSucceeded().listen(
        (_) => debugPrint('Realtime[DBG]: subscribed to $channelName'),
      );
      entry.channel.bindToAll().listen(
        (e) => debugPrint(
          'Realtime[DBG]: $channelName got "${e.name}" data=${e.data}',
        ),
      );
    }

    final StreamSubscription<ChannelReadEvent> sub = entry.channel
        .bind(eventName)
        .listen((event) {
          final Map<String, dynamic>? data = event.tryGetDataAsMap();
          debugPrint('Realtime[DBG]: handling $eventName parsed=$data');
          if (data == null) return;
          try {
            handler(data);
          } catch (e) {
            // حدث بشكل غير متوقع لا يجب أن يوقف باقي الأحداث
            debugPrint('Realtime: bad $eventName payload: $e');
          }
        });

    // الاتصال قائم من قبل: نشترك الآن، وإلا فـ onConnectionEstablished يشترك
    if (_connectionCount > 0) entry.channel.subscribeIfNotUnsubscribed();

    return RealtimeSubscription._(() {
      sub.cancel();
      entry.refs--;
      if (entry.refs > 0) return;
      entry.channel.unsubscribe();
      _channels.remove(channelName);
      if (_channels.isEmpty) disconnect();
    });
  }

  PusherChannelsClient _ensureClient() {
    final PusherChannelsClient? existing = _client;
    if (existing != null) return existing;

    final PusherChannelsClient client = PusherChannelsClient.websocket(
      options: PusherChannelsOptions.fromHost(
        scheme: RealtimeConfig.scheme,
        host: RealtimeConfig.host,
        port: RealtimeConfig.port,
        key: RealtimeConfig.appKey,
      ),
      // أي خطأ اتصال: نعيد المحاولة (المكتبة تضع فاصلاً بين المحاولات)
      connectionErrorHandler: (exception, trace, refresh) {
        debugPrint('Realtime: connection error: $exception');
        refresh();
      },
    );

    _connectionSub = client.onConnectionEstablished.listen((_) {
      _connectionCount++;
      debugPrint('Realtime[DBG]: connected (#$_connectionCount)');
      for (final entry in _channels.values) {
        entry.channel.subscribeIfNotUnsubscribed();
      }
      // الاتصال الأول لا يحتاج إعادة جلب، لأن الشاشة جلبت بياناتها قبله
      if (_connectionCount > 1) _reconnected.add(null);
    });

    client.connect();
    _client = client;
    return client;
  }

  // عند الخروج أو انتهاء الجلسة: نغلق كل شيء. التوكن الجديد يحتاج اتصالاً جديداً
  void disconnect() {
    _connectionSub?.cancel();
    _connectionSub = null;
    _connectionCount = 0;
    _channels.clear();
    final PusherChannelsClient? client = _client;
    _client = null;
    client?.dispose();
  }
}

class _ChannelEntry {
  final PrivateChannel channel;
  int refs = 0;

  _ChannelEntry(this.channel);
}

// توقيع الاشتراك: POST /broadcasting/auth بجسم JSON وبـ Authorization: Bearer <JWT>.
// نمرّ عبر ApiClient فيضيف الـ header تلقائياً، وانتهاء التوكن (401) ينهي الجلسة.
// الرد: { "auth": "<توقيع>" }، و403 يعني أن القناة ليست لهذا المستخدم
class _JwtAuthorizationDelegate
    implements
        EndpointAuthorizableChannelAuthorizationDelegate<
          PrivateChannelAuthorizationData
        > {
  @override
  EndpointAuthFailedCallback? get onAuthFailed =>
      (exception, trace) => debugPrint('Realtime: auth failed: $exception');

  @override
  Future<PrivateChannelAuthorizationData> authorizationData(
    String socketId,
    String channelName,
  ) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.broadcastingAuth,
      body: {'socket_id': socketId, 'channel_name': channelName},
    );

    final String? auth = response is Map
        ? (response['auth'] ??
                  (response['data'] is Map ? response['data']['auth'] : null))
              ?.toString()
        : null;
    if (auth == null || auth.isEmpty) {
      throw const FormatException('broadcasting/auth: missing "auth"');
    }
    return PrivateChannelAuthorizationData(authKey: auth);
  }
}
