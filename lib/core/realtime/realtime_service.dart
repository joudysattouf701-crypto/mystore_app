import 'dart:async';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';
import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'order_events.dart';

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

class RealtimeService {
  RealtimeService._();
  static final RealtimeService instance = RealtimeService._();

  PusherChannelsClient? _client;
  StreamSubscription<void>? _connectionSub;
  int _connectionCount = 0;

  final Map<String, _ChannelEntry> _channels = {};
  final StreamController<void> _reconnected = StreamController.broadcast();

  Stream<void> get onReconnected => _reconnected.stream;

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
            debugPrint('Realtime: bad $eventName payload: $e');
          }
        });

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
      if (_connectionCount > 1) _reconnected.add(null);
    });

    client.connect();
    _client = client;
    return client;
  }

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
