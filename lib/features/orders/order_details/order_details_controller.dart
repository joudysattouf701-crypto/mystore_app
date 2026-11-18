import 'dart:async';
import 'package:mystore/core/network/api_exception.dart';
import 'package:mystore/core/realtime/order_events.dart';
import 'package:mystore/core/realtime/realtime_service.dart';
import 'package:mystore/features/authentication/auth_session.dart';
import 'package:mystore/features/orders/order_model.dart';
import 'package:get/get.dart';
import 'order_details_model.dart';
import 'order_details_service.dart';

class OrderDetailsController extends GetxController {
  final int orderId;

  OrderDetailsController({required this.orderId, OrderModel? initial}) {
    // نعرض الطلب القادم من القائمة فوراً، ثم نجلب التفاصيل مع سجل الحالات
    order.value = initial;
  }

  final OrderDetailsService _detailsService = OrderDetailsService();

  var order = Rxn<OrderModel>();
  var isLoading = false.obs;
  var errorMessage = RxnString();

  // وصلت التفاصيل من السيرفر، فسجل الحالات أصبح متاحاً
  var isLoaded = false.obs;

  // الطلب غير موجود أو لا يخص الزبون (404)
  var notFound = false.obs;

  RealtimeSubscription? _statusSub;
  StreamSubscription<void>? _reconnectSub;

  @override
  void onInit() {
    super.onInit();
    fetchOrder();
    _listenRealtime();
  }

  // التحميل الأول من REST (القاعدة 1)، والتحديثات من الـ WebSocket
  void _listenRealtime() {
    final int? userId = AuthSession.to.user.value?.id;
    if (userId == null) return;

    _statusSub = RealtimeService.instance.watchStatusChanged(
      userId,
      _onStatusChanged,
    );

    // الأحداث وقت الانقطاع لا تُعاد، فنعيد الـ GET عند رجوع الاتصال (القاعدة 2)
    _reconnectSub = RealtimeService.instance.onReconnected.listen(
      (_) => fetchOrder(silent: true),
    );
  }

  void _onStatusChanged(OrderStatusChangedEvent event) {
    // قناة المستخدم تحمل أحداث كل طلباته، فنتجاهل أي طلب غير هذا (القاعدة 4)
    if (event.orderId != orderId) return;

    final OrderModel? current = order.value;
    if (current == null) return;

    // نفس الحدث لو وصل مرتين لا يغيّر شيئاً (القاعدة 3)
    if (current.status == event.to) return;

    final List<OrderStatusChangeModel> history = [
      ...current.statusHistory,
      OrderStatusChangeModel(
        from: event.from,
        to: event.to,
        changedAt: DateTime.now().toUtc(),
      ),
    ];
    order.value = current.copyWith(
      status: event.to,
      statusHistory: history,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  // silent: تحديث بالخلفية بدون مؤشر تحميل ولا رسائل خطأ
  Future<void> fetchOrder({bool silent = false}) async {
    try {
      if (!silent) {
        isLoading.value = true;
        errorMessage.value = null;
      }

      OrderDetailsModel result = await _detailsService.getOrder(orderId);
      order.value = result.order;
      isLoaded.value = true;
    } on ApiException catch (e) {
      if (e.statusCode == 401 || silent) return;
      if (e.statusCode == 404) {
        notFound.value = true;
      } else {
        errorMessage.value = e.displayMessage;
      }
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  // إغلاق الاشتراك عند الخروج من الصفحة (القاعدة 5)
  @override
  void onClose() {
    _statusSub?.cancel();
    _reconnectSub?.cancel();
    super.onClose();
  }
}
