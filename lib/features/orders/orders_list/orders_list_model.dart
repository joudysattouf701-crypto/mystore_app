import 'package:mystore/core/models/pagination_meta.dart';
import 'package:mystore/features/orders/order_model.dart';

// صفحة واحدة من قائمة الطلبات. الرد: { data: [Order], meta: {...} }
class OrdersListModel {
  final List<OrderModel> orders;
  final PaginationMeta meta;

  OrdersListModel({required this.orders, required this.meta});

  factory OrdersListModel.fromJson(Map<String, dynamic> json) {
    final List data = json['data'] ?? [];
    return OrdersListModel(
      orders: data.map((item) => OrderModel.fromJson(item)).toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': orders.map((order) => order.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}
