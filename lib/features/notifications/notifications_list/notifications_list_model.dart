import 'package:mystore/core/models/pagination_meta.dart';
import 'package:mystore/features/notifications/notification_model.dart';

// صفحة واحدة من قائمة الإشعارات. الرد: { data: [Notification], meta: {...} }
class NotificationsListModel {
  final List<NotificationModel> notifications;
  final PaginationMeta meta;

  NotificationsListModel({required this.notifications, required this.meta});

  factory NotificationsListModel.fromJson(Map<String, dynamic> json) {
    final List data = json['data'] ?? [];
    return NotificationsListModel(
      notifications: data
          .map((item) => NotificationModel.fromJson(item))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': notifications
          .map((notification) => notification.toJson())
          .toList(),
      'meta': meta.toJson(),
    };
  }
}
