import 'package:mystore/features/orders/order_model.dart';

class OrderStatusChangedEvent {
  final int orderId;
  final OrderStatus from;
  final OrderStatus to;

  OrderStatusChangedEvent({
    required this.orderId,
    required this.from,
    required this.to,
  });

  factory OrderStatusChangedEvent.fromJson(Map<String, dynamic> json) {
    return OrderStatusChangedEvent(
      orderId: _asInt(json['order_id']),
      from: OrderStatus.fromJson(json['from_status']),
      to: OrderStatus.fromJson(json['to_status']),
    );
  }
}

int _asInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
