import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'order_details_model.dart';

class OrderDetailsService {
  final ApiClient _api = ApiClient.instance;

  Future<OrderDetailsModel> getOrder(int id) async {
    final response = await _api.get(ApiEndpoints.order(id));

    return OrderDetailsModel.fromJson(response);
  }
}
