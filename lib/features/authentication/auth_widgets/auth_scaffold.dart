import 'package:mystore/core/theme/app_colors.dart';
import 'package:mystore/core/widgets/app_brand.dart';
import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  final Widget? footer;

  const AuthScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final bool canGoBack = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          PositionedDirectional(
            top: -140,
            end: -100,
            child: _Blob(
              size: 320,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          PositionedDirectional(
            top: 70,
            end: 40,
            child: _Blob(
              size: 22,
              color: AppColors.accent.withValues(alpha: 0.9),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 48,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: canGoBack ? const _BackButton() : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AppLogo(size: 64),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      child,
                      if (footer != null) ...[
                        const SizedBox(height: 20),
                        footer!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back, color: AppColors.text, size: 20),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
