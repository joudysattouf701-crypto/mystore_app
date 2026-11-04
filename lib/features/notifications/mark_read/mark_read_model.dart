import 'package:mystore/features/notifications/notification_model.dart';

// رد تعليم الإشعار كمقروء: { data: Notification } ومعه وقت القراءة
class MarkReadModel {
  final NotificationModel notification;

  MarkReadModel({required this.notification});

  factory MarkReadModel.fromJson(Map<String, dynamic> json) {
    return MarkReadModel(
      notification: NotificationModel.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': notification.toJson()};
  }
}
