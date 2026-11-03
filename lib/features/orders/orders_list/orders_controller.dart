import 'package:mystore/core/network/api_exception.dart';
import 'package:mystore/core/utils/app_snackbar.dart';
import 'package:mystore/features/orders/order_model.dart';
import 'package:get/get.dart';
import 'orders_list_model.dart';
import 'orders_list_service.dart';

class OrdersController extends GetxController {
  static const int _perPage = 15;

  final OrdersListService _ordersService = OrdersListService();

  // null يعني "الكل"
  var selectedStatus = Rxn<OrderStatus>();

  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;

  // رسالة فشل تحميل الصفحة الأولى، تظهر مع زر إعادة المحاولة
  var errorMessage = RxnString();

  int _page = 1;
  int _lastPage = 1;
  bool get hasMore => _page < _lastPage;

  // رقم آخر طلب، حتى نتجاهل رد فلتر قديم إن بدّل الزبون الحالة بسرعة
  int _requestId = 0;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  void selectStatus(OrderStatus? status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    fetchOrders();
  }

  // تحميل الصفحة الأولى من جديد (عند الفتح، وتبديل الحالة، والسحب للتحديث)
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

  // الصفحة التالية عند الوصول لآخر القائمة
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
