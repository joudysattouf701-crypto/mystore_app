import 'package:mystore/core/network/api_exception.dart';
import 'package:mystore/core/utils/app_snackbar.dart';
import 'package:mystore/features/cart/cart_controller.dart';
import 'package:mystore/features/cart/cart_model.dart';
import 'package:mystore/features/orders/order_model.dart';
import 'package:mystore/features/orders/orders_list/orders_controller.dart';
import 'package:mystore/features/orders/orders_list/orders_screen.dart';
import 'package:get/get.dart';
import 'create_order_model.dart';
import 'create_order_service.dart';

class CreateOrderController extends GetxController {
  final CreateOrderService _createOrderService = CreateOrderService();

  var isLoading = false.obs;
  var createdOrder = Rxn<OrderModel>();

  // إرسال محتوى السلة كطلب جديد، ثم إفراغها والانتقال لقائمة الطلبات
  Future<void> submit() async {
    final List<CartItemModel> items = CartController.to.items.toList();
    if (items.isEmpty || isLoading.value) return;

    try {
      isLoading.value = true;

      CreateOrderModel result = await _createOrderService.createOrder(items);
      createdOrder.value = result.order;

      CartController.to.clear();
      // إن كانت قائمة الطلبات مفتوحة مسبقاً نحدّثها لتظهر الطلب الجديد
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().fetchOrders();
      }

      Get.off(() => const OrdersScreen());
      AppSnackbar.success(
        'رقم طلبك #${result.order.id}، وهو الآن قيد الانتظار',
        title: 'تم إرسال الطلب',
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) return;
      AppSnackbar.error(_errorMessage(e, items));
    } finally {
      isLoading.value = false;
    }
  }

  // أخطاء العناصر تأتي بمفاتيح مثل items.0.product_id، فنضع اسم المنتج بدل الرقم
  String _errorMessage(ApiException e, List<CartItemModel> items) {
    if (e.errors.isEmpty) return e.displayMessage;

    return e.errors.entries
        .map((entry) {
          final match = RegExp(r'^items\.(\d+)').firstMatch(entry.key);
          final int? index = match != null ? int.parse(match.group(1)!) : null;
          final String message = entry.value.first;

          return index != null && index < items.length
              ? '${items[index].product.name}: $message'
              : message;
        })
        .join('\n');
  }
}
