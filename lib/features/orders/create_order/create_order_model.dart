import 'package:mystore/features/orders/order_model.dart';

class CreateOrderModel {
  final OrderModel order;

  CreateOrderModel({required this.order});

  factory CreateOrderModel.fromJson(Map<String, dynamic> json) {
    return CreateOrderModel(order: OrderModel.fromJson(json['data'] ?? {}));
  }

  Map<String, dynamic> toJson() {
    return {'data': order.toJson()};
  }
}
