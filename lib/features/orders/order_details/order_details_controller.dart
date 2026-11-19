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
    order.value = initial;
  }

  final OrderDetailsService _detailsService = OrderDetailsService();

  var order = Rxn<OrderModel>();
  var isLoading = false.obs;
  var errorMessage = RxnString();

  var isLoaded = false.obs;

  var notFound = false.obs;

  RealtimeSubscription? _statusSub;
  StreamSubscription<void>? _reconnectSub;

  @override
  void onInit() {
    super.onInit();
    fetchOrder();
    _listenRealtime();
  }

  void _listenRealtime() {
    final int? userId = AuthSession.to.user.value?.id;
    if (userId == null) return;

    _statusSub = RealtimeService.instance.watchStatusChanged(
      userId,
      _onStatusChanged,
    );

    _reconnectSub = RealtimeService.instance.onReconnected.listen(
      (_) => fetchOrder(silent: true),
    );
  }

  void _onStatusChanged(OrderStatusChangedEvent event) {
    if (event.orderId != orderId) return;

    final OrderModel? current = order.value;
    if (current == null) return;

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

  @override
  void onClose() {
    _statusSub?.cancel();
    _reconnectSub?.cancel();
    super.onClose();
  }
}
