import 'package:mystore/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../cart_controller.dart';

// عدد القطع في السلة فوق أي زر، ويختفي حين تكون السلة فارغة
class CartBadge extends StatelessWidget {
  final Widget child;

  const CartBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final int count = CartController.to.count;
      return Badge(
        isLabelVisible: count > 0,
        backgroundColor: AppColors.accent,
        textColor: Colors.white,
        label: Text(count > 99 ? '99+' : '$count'),
        child: child,
      );
    });
  }
}
