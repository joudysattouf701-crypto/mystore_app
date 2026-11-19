import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mystore/core/network/api_exception.dart';
import 'package:mystore/core/realtime/order_events.dart';
import 'package:mystore/core/realtime/realtime_service.dart';
import 'package:mystore/features/authentication/auth_session.dart';
import 'package:mystore/core/utils/app_snackbar.dart';
import 'package:mystore/features/orders/order_model.dart';
import 'package:get/get.dart';
import 'orders_list_model.dart';
import 'orders_list_service.dart';

class OrdersController extends GetxController {
  static const int _perPage = 15;

  final OrdersListService _ordersService = OrdersListService();

  var selectedStatus = Rxn<OrderStatus>();

  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;

  var errorMessage = RxnString();

  int _page = 1;
  int _lastPage = 1;
  bool get hasMore => _page < _lastPage;

  int _requestId = 0;

  RealtimeSubscription? _statusSub;
  StreamSubscription<void>? _reconnectSub;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();

    final int? userId = AuthSession.to.user.value?.id;
    debugPrint('Realtime[DBG]: OrdersController.onInit userId=$userId');
    if (userId != null) {
      _statusSub = RealtimeService.instance.watchStatusChanged(
        userId,
        _onStatusChanged,
      );
      _reconnectSub = RealtimeService.instance.onReconnected.listen(
        (_) => fetchOrders(),
      );
    }
  }

  void _onStatusChanged(OrderStatusChangedEvent event) {
    final int index = orders.indexWhere((order) => order.id == event.orderId);
    if (index == -1 || orders[index].status == event.to) return;

    final OrderStatus? filter = selectedStatus.value;
    if (filter != null && filter != event.to) {
      orders.removeAt(index);
      return;
    }
    orders[index] = orders[index].copyWith(status: event.to);
  }

  @override
  void onClose() {
    _statusSub?.cancel();
    _reconnectSub?.cancel();
    super.onClose();
  }

  void selectStatus(OrderStatus? status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final int request = ++_requestId;

    try {
      isLoading.value = true;
      errorMessage.value = null;

      OrdersListModel result = await _ordersService.getOrders(
        status: selectedStatus.value,
        page: 1,
        perPage: _perPage,
      );
      if (request != _requestId) return;

      orders.value = result.orders;
      _page = result.meta.currentPage;
      _lastPage = result.meta.lastPage;
    } on ApiException catch (e) {
      if (request != _requestId) return;
      errorMessage.value = e.displayMessage;
    } finally {
      if (request == _requestId) isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore) return;
    final int request = _requestId;

    try {
      isLoadingMore.value = true;

      OrdersListModel result = await _ordersService.getOrders(
        status: selectedStatus.value,
        page: _page + 1,
        perPage: _perPage,
      );
      if (request != _requestId) return;

      orders.addAll(result.orders);
      _page = result.meta.currentPage;
      _lastPage = result.meta.lastPage;
    } on ApiException catch (e) {
      if (request == _requestId) AppSnackbar.apiError(e);
    } finally {
      isLoadingMore.value = false;
    }
  }
}
