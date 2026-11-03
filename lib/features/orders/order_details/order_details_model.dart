import 'package:mystore/features/orders/order_model.dart';

// رد تفاصيل الطلب: { data: Order } ومعه سجل تغييرات الحالة
class OrderDetailsModel {
  final OrderModel order;

  OrderDetailsModel({required this.order});

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(order: OrderModel.fromJson(json['data'] ?? {}));
  }

  Map<String, dynamic> toJson() {
    return {'data': order.toJson()};
  }
}
