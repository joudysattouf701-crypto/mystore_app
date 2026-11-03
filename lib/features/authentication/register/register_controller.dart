import 'package:mystore/core/network/api_exception.dart';
import 'package:mystore/core/utils/app_snackbar.dart';
import 'package:mystore/features/authentication/auth_session.dart';
import 'package:mystore/features/products/products_list/products_screen.dart';
import 'package:get/get.dart';
import 'register_model.dart';
import 'register_service.dart';

class RegisterController extends GetxController {
  final RegisterService _registerService = RegisterService();

  var isLoading = false.obs;
  var registerModel = Rxn<RegisterModel>();

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      RegisterModel result = await _registerService.registerUser(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      registerModel.value = result;

      await AuthSession.to.start(
        accessToken: result.accessToken,
        user: result.user,
      );

      Get.offAll(() => const ProductsScreen());
      AppSnackbar.success('تم إنشاء حسابك بنجاح');
    } on ApiException catch (e) {
      AppSnackbar.error(e.displayMessage);
    } finally {
      isLoading.value = false;
    }
  }
}
