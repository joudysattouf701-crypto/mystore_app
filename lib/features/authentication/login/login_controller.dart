import 'package:mystore/core/network/api_exception.dart';
import 'package:mystore/core/utils/app_snackbar.dart';
import 'package:mystore/features/authentication/auth_session.dart';
import 'package:mystore/features/products/products_list/products_screen.dart';
import 'package:get/get.dart';
import 'login_model.dart';
import 'login_service.dart';

class LoginController extends GetxController {
  final LoginService _loginService = LoginService();

  var isLoading = false.obs;
  var loginModel = Rxn<LoginModel>();

  Future<void> login({required String email, required String password}) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      LoginModel result = await _loginService.login(
        email: email,
        password: password,
      );

      if (!result.user.isCustomer) {
        AppSnackbar.error('هذا التطبيق مخصص للزبائن فقط');
        return;
      }

      loginModel.value = result;
      await AuthSession.to.start(
        accessToken: result.accessToken,
        user: result.user,
      );

      Get.offAll(() => const ProductsScreen());
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
    } finally {
      isLoading.value = false;
    }
  }
}
