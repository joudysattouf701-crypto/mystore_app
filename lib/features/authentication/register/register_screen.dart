import 'package:mystore/features/authentication/auth_widgets/auth_scaffold.dart';
import 'package:mystore/features/authentication/auth_widgets/auth_footer.dart';
import 'package:mystore/core/widgets/app_text_field.dart';
import 'package:mystore/core/utils/app_validators.dart';
import 'package:mystore/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final RegisterController controller = Get.put(RegisterController());

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      controller.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'إنشاء حساب',
      subtitle: 'أنشئ حسابك وابدأ التسوق خلال لحظات',
      footer: AuthFooter(
        question: 'لديك حساب مسبقاً؟',
        action: 'سجّل الدخول',
        // العودة لشاشة تسجيل الدخول دون تكديس الصفحات فوق بعضها
        onTap: () => Get.back(),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'الاسم',
              hint: 'أدخل اسمك',
              icon: Icons.person_outline_rounded,
              validator: AppValidators.name,
            ),
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
              hint: '8 أحرف على الأقل، حرف ورقم',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              validator: AppValidators.password,
            ),
            AppTextField(
              controller: _confirmPasswordController,
              label: 'تأكيد كلمة المرور',
              hint: 'أعد كتابة كلمة المرور',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitForm(),
              validator: AppValidators.confirmPassword(
                () => _passwordController.text,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => AppButton(
                label: 'إنشاء الحساب',
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
