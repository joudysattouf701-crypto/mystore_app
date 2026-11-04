import 'package:mystore/core/theme/app_theme.dart';
import 'package:mystore/features/authentication/auth_session.dart';
import 'package:mystore/features/cart/cart_controller.dart';
import 'package:mystore/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart'; // استيراد مكتبة GetX للتعامل مع الـ GetMaterialApp والإشعارات

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // استرجاع الجلسة المحفوظة قبل تشغيل التطبيق لتحديد شاشة البداية
  await Get.putAsync(() => AuthSession().init());

  // السلة مشتركة بين كل الشاشات وتبقى طوال تشغيل التطبيق
  Get.put(CartController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدمنا GetMaterialApp بدلاً من MaterialApp لكي تعمل إشعارات Get.snackbar بسلاسة
    return GetMaterialApp(
      debugShowCheckedModeBanner: false, // لإخفاء شريط الـ Debug
      title: 'متجري',
      theme: AppTheme.light,
      // التطبيق عربي فقط: الواجهة من اليمين لليسار ونصوص Flutter الجاهزة بالعربية
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // حركة انتقال واحدة بين كل الشاشات
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      // شاشة البداية تقرر بعدها: الرئيسية للمسجّل، وتسجيل الدخول لغيره
      home: const SplashScreen(),
    );
  }
}
