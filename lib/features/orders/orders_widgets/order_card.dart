import 'package:mystore/core/theme/app_colors.dart';
import 'package:mystore/core/utils/app_date.dart';
import 'package:mystore/core/utils/app_money.dart';
import 'package:mystore/core/widgets/skeleton.dart';
import 'package:mystore/features/orders/order_model.dart';
import 'package:flutter/material.dart';
import 'order_status_badge.dart';

// بطاقة طلب في القائمة: الرقم والتاريخ والحالة، ثم المنتجات، ثم المجموع
class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  // نعرض أول منتجين فقط ونلخّص الباقي بسطر واحد
  static const int _visibleItems = 2;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    final int hiddenItems = order.items.length - _visibleItems;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.border, height: 1),
              ),
              for (final item in order.items.take(_visibleItems))
                _buildItem(item),
              if (hiddenItems > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    hiddenItems == 1
                        ? '+ منتج آخر'
                        : '+ $hiddenItems منتجات أخرى',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            size: 22,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'طلب #${order.id}',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (order.createdAt != null) ...[
                const SizedBox(height: 2),
                Text(
                  AppDate.format(order.createdAt!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        OrderStatusBadge(status: order.status),
      ],
    );
  }

  Widget _buildItem(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: AppColors.text),
            ),
          ),
          Text(
            '× ${item.quantity}',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Text(
            AppMoney.format(item.subtotal),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            order.quantity == 1 ? 'قطعة واحدة' : '${order.quantity} قطع',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const Spacer(),
          const Text(
            'المجموع  ',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          Text(
            AppMoney.format(order.total),
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// بطاقة هيكلية بنفس شكل بطاقة الطلب تظهر أثناء التحميل
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 42, height: 42),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 90, height: 14),
                    SizedBox(height: 6),
                    SkeletonBox(width: 60, height: 12),
                  ],
                ),
              ),
              SkeletonBox(width: 76, height: 24, radius: 20),
            ],
          ),
          SizedBox(height: 20),
          SkeletonBox(width: 180, height: 14),
          SizedBox(height: 10),
          SkeletonBox(width: 140, height: 14),
          SizedBox(height: 16),
          SkeletonBox(height: 40),
        ],
      ),
    );
  }
}
