import 'package:mystore/features/orders/order_model.dart';

// إشعار كما يرجعه السيرفر. محتوى data يختلف حسب النوع
class NotificationModel {
  // النوع الوحيد حالياً: تغيّر حالة طلب
  static const String orderStatusChanged = 'order_status_changed';

  final int id;
  final String type;
  final String title;
  final Map<String, dynamic> data;

  // null يعني أن الإشعار غير مقروء
  final DateTime? readAt;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    this.data = const {},
    this.readAt,
    this.createdAt,
  });

  bool get isRead => readAt != null;

  // رقم الطلب المرتبط بالإشعار إن وُجد
  int? get orderId => data['order_id'];

  OrderStatus? get orderStatus =>
      data['status'] != null ? OrderStatus.fromJson(data['status']) : null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : const {},
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'data': data,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
