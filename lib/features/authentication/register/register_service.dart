import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'register_model.dart';

class RegisterService {
  final ApiClient _api = ApiClient.instance;

  // الدور دائماً customer من جهة السيرفر، فلا نرسل role
  Future<RegisterModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final Map<String, dynamic> requestBody = {
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
    };

    final response = await _api.post(
      ApiEndpoints.register,
      auth: false,
      body: requestBody,
    );

    return RegisterModel.fromJson(response);
  }
}
