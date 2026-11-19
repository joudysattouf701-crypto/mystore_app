import 'package:mystore/core/theme/app_colors.dart';
import 'package:mystore/core/widgets/app_brand.dart';
import 'package:mystore/features/authentication/auth_session.dart';
import 'package:mystore/features/authentication/login/login_screen.dart';
import 'package:mystore/features/products/products_list/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _animationDuration = Duration(milliseconds: 1100);
  static const Duration _minStay = Duration(milliseconds: 1700);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _animationDuration,
  );

  late final Animation<double> _logo = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.65, curve: Curves.easeOutBack),
  );
  late final Animation<double> _text = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _goNext();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    await Future.wait([Future.delayed(_minStay), AuthSession.to.refreshUser()]);
    if (!mounted) return;

    Get.offAll(
      () => AuthSession.to.isLoggedIn.value
          ? const ProductsScreen()
          : const LoginScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: Tween<double>(begin: 0.6, end: 1).animate(_logo),
                child: FadeTransition(
                  opacity: _logo,
                  child: const AppLogo(size: 112, light: true),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _text,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(_text),
                  child: Column(
                    children: [
                      const Text(
                        'متجري',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'كل ما تحتاجه في مكان واحد',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
