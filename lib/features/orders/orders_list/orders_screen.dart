import 'package:mystore/core/widgets/empty_state.dart';
import 'package:mystore/core/widgets/skeleton.dart';
import 'package:mystore/features/orders/order_details/order_details_screen.dart';
import 'package:mystore/features/orders/orders_widgets/order_card.dart';
import 'package:mystore/features/orders/orders_widgets/order_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'orders_controller.dart';

// طلبات الزبون: فلتر الحالة في الأعلى ثم قائمة الطلبات من الأحدث
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrdersController controller = Get.put(OrdersController());

  // عند الاقتراب من آخر القائمة نحمّل الصفحة التالية
  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < 400) controller.loadMore();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: RefreshIndicator(
        onRefresh: controller.fetchOrders,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: Obx(
            () => CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: OrderStatusChips(
                      selected: controller.selectedStatus.value,
                      onSelected: controller.selectStatus,
                    ),
                  ),
                ),
                ..._buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    if (controller.isLoading.value && controller.orders.isEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: 4,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) =>
                const Shimmer(child: OrderCardSkeleton()),
          ),
        ),
      ];
    }

    final String? error = controller.errorMessage.value;
    if (error != null && controller.orders.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorState(message: error, onRetry: controller.fetchOrders),
        ),
      ];
    }

    if (controller.orders.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'لا توجد طلبات',
            message: controller.selectedStatus.value == null
                ? 'لم تقم بأي طلب بعد، تصفّح المتجر واطلب ما يعجبك'
                : 'لا توجد طلبات بحالة "${controller.selectedStatus.value!.label}"',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.separated(
          itemCount: controller.orders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return OrderCard(
              order: order,
              onTap: () => Get.to(
                () => OrderDetailsScreen(orderId: order.id, initial: order),
              ),
            );
          },
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: controller.isLoadingMore.value
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    ];
  }
}
