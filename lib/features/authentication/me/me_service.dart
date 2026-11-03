import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'me_model.dart';

class MeService {
  final ApiClient _api = ApiClient.instance;

  Future<UserModel> getMe() async {
    final response = await _api.get(ApiEndpoints.me);

    return UserModel.fromJson(response['data'] ?? {});
  }
}
