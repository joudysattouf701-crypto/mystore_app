import 'dart:convert';
import 'package:mystore/core/network/api_client.dart';
import 'package:mystore/core/network/api_exception.dart';
import 'package:mystore/core/storage/token_storage.dart';
import 'package:mystore/core/utils/app_snackbar.dart';
import 'package:get/get.dart';
import 'login/login_screen.dart';
import 'me/me_model.dart';
import 'me/me_service.dart';

class AuthSession extends GetxService {
  static AuthSession get to => Get.find<AuthSession>();

  final TokenStorage _storage = TokenStorage.instance;
  final MeService _meService = MeService();

  var isLoggedIn = false.obs;
  var user = Rxn<UserModel>();

  Future<AuthSession> init() async {
    await _storage.load();
    isLoggedIn.value = _storage.accessToken != null;

    final String? userJson = _storage.userJson;
    if (userJson != null) {
      try {
        user.value = UserModel.fromJson(jsonDecode(userJson));
      } catch (_) {
        await _storage.clear();
        isLoggedIn.value = false;
      }
    }

    ApiClient.instance.onSessionExpired = _onSessionExpired;
    return this;
  }

  Future<void> start({
    required String accessToken,
    required UserModel user,
  }) async {
    await _storage.saveToken(accessToken);
    isLoggedIn.value = true;
    await updateUser(user);
  }

  Future<void> updateUser(UserModel updated) async {
    user.value = updated;
    await _storage.saveUser(jsonEncode(updated.toJson()));
  }

  Future<void> refreshUser() async {
    if (!isLoggedIn.value) return;

    final UserModel fresh;
    try {
      fresh = await _meService.getMe();
    } on ApiException {
      return;
    }

    if (!fresh.isCustomer) {
      await _end();
      return;
    }
    await updateUser(fresh);
  }

  Future<void> logout() => _end();

  void _onSessionExpired() {
    if (!isLoggedIn.value) return;
    _end();
    AppSnackbar.error('سجّل الدخول مجدداً للمتابعة', title: 'انتهت الجلسة');
  }

  Future<void> _end() async {
    isLoggedIn.value = false;
    user.value = null;
    await _storage.clear();
    Get.offAll(() => const LoginScreen());
  }
}
