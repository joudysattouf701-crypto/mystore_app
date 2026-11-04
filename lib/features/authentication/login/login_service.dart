import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_endpoints.dart';
import 'login_model.dart';

class LoginService {
  final ApiClient _api = ApiClient.instance;

  // تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<LoginModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      ApiEndpoints.login,
      auth: false,
      body: {"email": email, "password": password},
    );

    return LoginModel.fromJson(response);
  }
}
