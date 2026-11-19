import 'package:mystore/features/authentication/auth_widgets/auth_scaffold.dart';
import 'package:mystore/features/authentication/auth_widgets/auth_footer.dart';
import 'package:mystore/core/widgets/app_text_field.dart';
import 'package:mystore/core/utils/app_validators.dart';
import 'package:mystore/features/authentication/register/register_screen.dart';
import 'package:mystore/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final LoginController controller = Get.put(LoginController());

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      controller.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'أهلاً بعودتك',
      subtitle: 'سجّل دخولك لمتابعة التسوق',
      footer: AuthFooter(
        question: 'ليس لديك حساب؟',
        action: 'أنشئ حساباً',
        onTap: () => Get.to(() => const RegisterScreen()),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hint: 'name@example.com',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              ltrInput: true,
              validator: AppValidators.email,
            ),
            AppTextField(
              controller: _passwordController,
              label: 'كلمة المرور',
              hint: 'أدخل كلمة المرور',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitForm(),
            ),
            const SizedBox(height: 12),
            Obx(
              () => AppButton(
                label: 'تسجيل الدخول',
                isLoading: controller.isLoading.value,
                onPressed: _submitForm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
