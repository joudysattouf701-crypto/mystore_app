import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'package:mystore/features/cart/cart_model.dart';
import 'create_order_model.dart';

class CreateOrderService {
  final ApiClient _api = ApiClient.instance;

  // نرسل رقم المنتج والكمية فقط، والسيرفر يجلب السعر من خدمة المنتجات
  Future<CreateOrderModel> createOrder(List<CartItemModel> items) async {
    final response = await _api.post(
      ApiEndpoints.orders,
      body: {"items": items.map((item) => item.toJson()).toList()},
    );

    return CreateOrderModel.fromJson(response);
  }
}
