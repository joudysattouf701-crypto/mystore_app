import 'package:mystore/core/theme/app_colors.dart';
import 'package:mystore/features/orders/order_model.dart';
import 'package:flutter/material.dart';

// لون وأيقونة كل حالة، حتى يميّز الزبون حالة طلبه بنظرة
extension OrderStatusStyle on OrderStatus {
  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.accent;
      case OrderStatus.confirmed:
        return const Color(0xff2F6FDB);
      case OrderStatus.shipped:
        return const Color(0xff7A4FD1);
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.schedule_rounded;
      case OrderStatus.confirmed:
        return Icons.task_alt_rounded;
      case OrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.inventory_2_outlined;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

// شارة صغيرة بلون الحالة واسمها
class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              color: status.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// شريط أفقي لفلترة الطلبات حسب الحالة يبدأ بـ "الكل". الاختيار null يعني "الكل"
class OrderStatusChips extends StatelessWidget {
  final OrderStatus? selected;
  final ValueChanged<OrderStatus?> onSelected;

  const OrderStatusChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildChip('الكل', null),
          for (final status in OrderStatus.values)
            _buildChip(status.label, status),
        ],
      ),
    );
  }

  Widget _buildChip(String label, OrderStatus? status) {
    final bool isSelected = selected == status;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: () => onSelected(status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : AppColors.text,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
