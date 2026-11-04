import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'package:mystore/features/orders/order_model.dart';
import 'orders_list_model.dart';

class OrdersListService {
  final ApiClient _api = ApiClient.instance;

  // تحتاج توكن، والسيرفر يرجع للزبون طلباته فقط
  Future<OrdersListModel> getOrders({
    OrderStatus? status,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _api.get(
      ApiEndpoints.orders,
      query: {
        if (status != null) "status": status.value,
        "page": '$page',
        "per_page": '$perPage',
      },
    );

    return OrdersListModel.fromJson(response);
  }
}
