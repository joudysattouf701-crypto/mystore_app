import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'product_details_model.dart';

class ProductDetailsService {
  final ApiClient _api = ApiClient.instance;

  // تفاصيل منتج واحد. الرد: { data: Product }، والمنتج غير الموجود يرجع 404
  Future<ProductModel> getProduct(int id) async {
    final response = await _api.get(
      ApiEndpoints.product(id),
      auth: false,
      etag: true,
    );

    return ProductModel.fromJson(response['data'] ?? {});
  }
}
