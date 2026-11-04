import 'package:mystore/core/theme/app_colors.dart';
import 'package:mystore/core/utils/app_date.dart';
import 'package:mystore/core/widgets/skeleton.dart';
import 'package:mystore/features/notifications/notification_model.dart';
import 'package:mystore/features/orders/orders_widgets/order_status_badge.dart';
import 'package:flutter/material.dart';

// إشعار في القائمة: أيقونة بلون حالة الطلب، العنوان والوقت، ونقطة لغير المقروء
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification.isRead;
    final Color color =
        notification.orderStatus?.color ?? AppColors.primary;
    final IconData icon =
        notification.orderStatus?.icon ?? Icons.notifications_none_rounded;

    return Material(
      color: isRead ? AppColors.surface : AppColors.primarySoft,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isRead
                  ? AppColors.border
                  : AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.text,
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        AppDate.formatWithTime(notification.createdAt!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsetsDirectional.only(start: 8, top: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// بطاقة هيكلية بنفس شكل الإشعار تظهر أثناء التحميل
class NotificationTileSkeleton extends StatelessWidget {
  const NotificationTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 42, height: 42),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 160, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 90, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// فلتر الإشعارات: "الكل" أو "غير المقروءة"
class NotificationFilterChips extends StatelessWidget {
  final bool unreadOnly;
  final ValueChanged<bool> onSelected;

  const NotificationFilterChips({
    super.key,
    required this.unreadOnly,
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
          _buildChip('الكل', false),
          _buildChip('غير المقروءة', true),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool value) {
    final bool isSelected = unreadOnly == value;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: () => onSelected(value),
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
