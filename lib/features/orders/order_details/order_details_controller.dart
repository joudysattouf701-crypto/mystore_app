import 'package:mystore/core/network/api_exception.dart';
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

  @override
  void onInit() {
    super.onInit();
    fetchOrder();
  }

  Future<void> fetchOrder() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      OrderDetailsModel result = await _detailsService.getOrder(orderId);
      order.value = result.order;
      isLoaded.value = true;
    } on ApiException catch (e) {
      if (e.statusCode == 401) return;
      if (e.statusCode == 404) {
        notFound.value = true;
      } else {
        errorMessage.value = e.displayMessage;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
