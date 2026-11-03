import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'categories_model.dart';

class CategoriesService {
  final ApiClient _api = ApiClient.instance;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _api.get(ApiEndpoints.categories, auth: false);

    final List data = response['data'] ?? [];
    return data.map((item) => CategoryModel.fromJson(item)).toList();
  }
}
