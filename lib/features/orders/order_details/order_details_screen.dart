import 'package:mystore/core/theme/app_colors.dart';
import 'package:mystore/core/utils/app_date.dart';
import 'package:mystore/core/utils/app_money.dart';
import 'package:mystore/core/widgets/empty_state.dart';
import 'package:mystore/features/orders/order_model.dart';
import 'package:mystore/features/orders/orders_widgets/order_status_badge.dart';
import 'package:mystore/features/orders/orders_widgets/order_status_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'order_details_controller.dart';

// تفاصيل طلب واحد: الحالة، ثم المنتجات والمجموع، ثم سجل تغييرات الحالة
class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  // نسخة الطلب من القائمة لعرضها فوراً قبل وصول التفاصيل
  final OrderModel? initial;

  const OrderDetailsScreen({super.key, required this.orderId, this.initial});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  // tag برقم الطلب حتى لا تتشارك شاشتا تفاصيل نفس الـ controller
  late final OrderDetailsController controller = Get.put(
    OrderDetailsController(orderId: widget.orderId, initial: widget.initial),
    tag: '${widget.orderId}',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلب #${widget.orderId}')),
      body: Obx(() {
        if (controller.notFound.value) {
          return const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'الطلب غير موجود',
            message: 'لم نجد هذا الطلب ضمن طلباتك',
          );
        }

        final OrderModel? order = controller.order.value;
        if (order != null) return _buildDetails(order);

        final String? error = controller.errorMessage.value;
        if (error != null) {
          return ErrorState(message: error, onRetry: controller.fetchOrder);
        }

        return const Center(child: CircularProgressIndicator());
      }),
    );
  }

  Widget _buildDetails(OrderModel order) {
    return RefreshIndicator(
      onRefresh: controller.fetchOrder,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _buildSection(child: _buildHeader(order)),
          const SizedBox(height: 14),
          _buildSection(
            title: 'المنتجات',
            child: Column(
              children: [
                for (final item in order.items) _buildItem(item),
                _buildTotal(order),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildSection(title: 'مسار الطلب', child: _buildHistory(order)),
        ],
      ),
    );
  }

  // بطاقة بيضاء بإطار وعنوان اختياري
  Widget _buildSection({String? title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildHeader(OrderModel order) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: order.status.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(order.status.icon, size: 26, color: order.status.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'حالة الطلب',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                order.status.label,
                style: TextStyle(
                  fontSize: 17,
                  color: order.status.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (order.createdAt != null)
          Text(
            AppDate.format(order.createdAt!),
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
      ],
    );
  }

  Widget _buildItem(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppMoney.format(item.unitPrice)} × ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            AppMoney.format(item.subtotal),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal(OrderModel order) {
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
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // السجل لا يأتي مع القائمة، فننتظر التفاصيل قبل عرضه
  Widget _buildHistory(OrderModel order) {
    if (controller.isLoaded.value) return OrderStatusTimeline(order: order);

    if (controller.isLoading.value) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    return Column(
      children: [
        Text(
          controller.errorMessage.value ?? 'تعذر تحميل مسار الطلب',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        TextButton.icon(
          onPressed: controller.fetchOrder,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('إعادة المحاولة'),
        ),
      ],
    );
  }
}
