import 'package:mystore/core/network/api_exception.dart';
import 'package:mystore/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// شكل موحّد لإشعارات النجاح والخطأ في كل التطبيق
class AppSnackbar {
  static void success(String message, {String title = 'تم'}) {
    _show(title, message, AppColors.success, Icons.check_circle_outline);
  }

  static void error(String message, {String title = 'خطأ'}) {
    _show(title, message, AppColors.error, Icons.error_outline);
  }

  // خطأ قادم من السيرفر. انتهاء الجلسة (401) له إشعاره الخاص فلا نكرره
  static void apiError(ApiException e) {
    if (e.statusCode == 401) return;
    error(e.displayMessage);
  }

  static void _show(String title, String message, Color color, IconData icon) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 4),
    );
  }
}
