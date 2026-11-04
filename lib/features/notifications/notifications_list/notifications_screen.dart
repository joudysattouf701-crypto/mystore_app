import 'package:mystore/core/widgets/empty_state.dart';
import 'package:mystore/core/widgets/skeleton.dart';
import 'package:mystore/features/notifications/notifications_widgets/notification_tile.dart';
import 'package:mystore/features/orders/order_details/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'notifications_controller.dart';

// إشعارات الزبون: فلتر المقروءة في الأعلى ثم القائمة من الأحدث
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsController controller = Get.put(
    NotificationsController(),
  );

  // عند الاقتراب من آخر القائمة نحمّل الصفحة التالية
  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < 400) controller.loadMore();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: RefreshIndicator(
        onRefresh: controller.fetchNotifications,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: Obx(
            () => CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: NotificationFilterChips(
                      unreadOnly: controller.unreadOnly.value,
                      onSelected: controller.selectUnreadOnly,
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
    if (controller.isLoading.value && controller.notifications.isEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: 6,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                const Shimmer(child: NotificationTileSkeleton()),
          ),
        ),
      ];
    }

    final String? error = controller.errorMessage.value;
    if (error != null && controller.notifications.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorState(
            message: error,
            onRetry: controller.fetchNotifications,
          ),
        ),
      ];
    }

    if (controller.notifications.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'لا توجد إشعارات',
            message: controller.unreadOnly.value
                ? 'قرأت كل إشعاراتك'
                : 'ستصلك هنا إشعارات تحديث حالة طلباتك',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.separated(
          itemCount: controller.notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            final int? orderId = notification.orderId;
            return NotificationTile(
              notification: notification,
              onTap: () {
                controller.markAsRead(notification);
                if (orderId != null) {
                  Get.to(() => OrderDetailsScreen(orderId: orderId));
                }
              },
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
