import 'package:mystore/core/theme/app_colors.dart';
import 'package:mystore/core/utils/app_date.dart';
import 'package:mystore/features/orders/order_model.dart';
import 'package:flutter/material.dart';
import 'order_status_badge.dart';

// مسار الطلب: إنشاؤه ثم كل تغيير في حالته من الأقدم للأحدث
class OrderStatusTimeline extends StatelessWidget {
  final OrderModel order;

  const OrderStatusTimeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final List<_TimelineEntry> entries = [
      _TimelineEntry(
        status: OrderStatus.pending,
        title: 'تم إنشاء الطلب',
        date: order.createdAt,
      ),
      for (final change in order.statusHistory)
        _TimelineEntry(
          status: change.to,
          title: change.to.label,
          note: change.note,
          date: change.changedAt,
        ),
    ];

    return Column(
      children: [
        for (int i = 0; i < entries.length; i++)
          _buildEntry(entries[i], isLast: i == entries.length - 1),
      ],
    );
  }

  Widget _buildEntry(_TimelineEntry entry, {required bool isLast}) {
    final String note = entry.note?.trim() ?? '';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الدائرة بلون الحالة، والخط يصلها بالخطوة التالية
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: entry.status.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  entry.status.icon,
                  size: 16,
                  color: entry.status.color,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4, bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (entry.date != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      AppDate.formatWithTime(entry.date!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      note,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEntry {
  final OrderStatus status;
  final String title;
  final String? note;
  final DateTime? date;

  _TimelineEntry({
    required this.status,
    required this.title,
    this.note,
    this.date,
  });
}
