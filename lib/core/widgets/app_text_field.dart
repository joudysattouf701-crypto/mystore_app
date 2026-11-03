import 'package:mystore/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mystore/core/utils/app_validators.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool isPassword;

  final bool optional;

  final bool ltrInput;

  final bool enabled;
  final int maxLines;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.isPassword = false,
    this.optional = false,
    this.ltrInput = false,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.validator,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final TextDirection ambient = Directionality.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: widget.label,
              children: [
                if (widget.optional)
                  const TextSpan(
                    text: '  (اختياري)',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.controller,
            obscureText: _obscured,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            onFieldSubmitted: widget.onSubmitted,
            textDirection: widget.ltrInput ? TextDirection.ltr : null,
            textAlign: widget.ltrInput && ambient == TextDirection.rtl
                ? TextAlign.right
                : TextAlign.start,
            style: TextStyle(
              fontSize: 15,
              color: widget.enabled ? AppColors.text : AppColors.textMuted,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintTextDirection: ambient,
              prefixIcon: Icon(widget.icon, size: 20),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      onPressed: () => setState(() => _obscured = !_obscured),
                      icon: Icon(
                        _obscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                    )
                  : null,
            ),
            validator:
                widget.validator ??
                (widget.optional ? null : AppValidators.required),
          ),
        ],
      ),
    );
  }
}
