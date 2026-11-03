import 'package:mystore/core/network/api_exception.dart';
import 'package:mystore/core/utils/app_snackbar.dart';
import 'package:mystore/features/authentication/auth_session.dart';
import 'package:mystore/features/products/products_list/products_screen.dart';
import 'package:get/get.dart';
import 'login_model.dart';
import 'login_service.dart';

class LoginController extends GetxController {
  // حقن الـ Service
  final LoginService _loginService = LoginService();

  // متغيرات لمراقبة الحالة وتحديث الـ UI تفاعلياً
  var isLoading = false.obs;
  var loginModel = Rxn<LoginModel>();

  // دالة تسجيل الدخول التي تربط الشاشة بالسيرفس
  Future<void> login({required String email, required String password}) async {
    try {
      isLoading.value = true; // بدء مؤشر التحميل

      LoginModel result = await _loginService.login(
        email: email,
        password: password,
      );

      // حساب الأدمن لا يدخل من تطبيق الزبون
      if (!result.user.isCustomer) {
        AppSnackbar.error('هذا التطبيق مخصص للزبائن فقط');
        return;
      }

      loginModel.value = result; // حفظ النتيجة داخل المتغير التفاعلي
      await AuthSession.to.start(
        accessToken: result.accessToken,
        user: result.user,
      );

      Get.offAll(() => const ProductsScreen());
    } on ApiException catch (e) {
      // عرض رسالة الخطأ في حال فشل العملية
      AppSnackbar.error(e.displayMessage);
    } finally {
      isLoading.value = false; // إيقاف مؤشر التحميل في جميع الحالات
    }
  }
}
