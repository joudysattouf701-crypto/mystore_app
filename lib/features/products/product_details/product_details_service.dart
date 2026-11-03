import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'product_details_model.dart';

class ProductDetailsService {
  final ApiClient _api = ApiClient.instance;

  Future<ProductModel> getProduct(int id) async {
    final response = await _api.get(ApiEndpoints.product(id), auth: false);

    return ProductModel.fromJson(response['data'] ?? {});
  }
}
