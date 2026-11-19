import 'package:mystore/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool light;

  const AppLogo({super.key, required this.size, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: light ? Colors.white : null,
        gradient: light
            ? null
            : const LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: light ? 0.25 : 0.3),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.shopping_bag_rounded,
            color: light ? AppColors.primary : Colors.white,
            size: size * 0.52,
          ),
          PositionedDirectional(
            top: size * 0.16,
            end: size * 0.16,
            child: Container(
              width: size * 0.16,
              height: size * 0.16,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
