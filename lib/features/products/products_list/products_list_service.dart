import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'products_list_model.dart';

class ProductsListService {
  final ApiClient _api = ApiClient.instance;

  // القائمة عامة لا تحتاج توكن. تصنيف غير موجود يرجع قائمة فارغة وليس خطأ
  Future<ProductsListModel> getProducts({
    int? categoryId,
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _api.get(
      ApiEndpoints.products,
      auth: false,
      query: {
        if (categoryId != null) "category_id": '$categoryId',
        "page": '$page',
        "per_page": '$perPage',
      },
    );

    return ProductsListModel.fromJson(response);
  }
}
