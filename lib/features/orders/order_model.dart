// حالات الطلب كما يرسلها السيرفر، مع اسمها بالعربية
enum OrderStatus {
  pending('pending', 'قيد الانتظار'),
  confirmed('confirmed', 'مؤكد'),
  shipped('shipped', 'تم الشحن'),
  delivered('delivered', 'تم التوصيل'),
  cancelled('cancelled', 'ملغي');

  final String value;
  final String label;

  const OrderStatus(this.value, this.label);

  // حالة غير معروفة نعرضها كـ "قيد الانتظار" بدل أن يفشل التحويل
  static OrderStatus fromJson(dynamic value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

// الطلب كما يرجعه السيرفر. سجل الحالات لا يأتي ضمن القائمة فيبقى فارغاً هناك
class OrderModel {
  final int id;
  final int customerId;
  final OrderStatus status;
  final List<OrderItemModel> items;

  // المجموع بالليرة السورية
  final int total;
  final List<OrderStatusChangeModel> statusHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.status,
    required this.items,
    required this.total,
    this.statusHistory = const [],
    this.createdAt,
    this.updatedAt,
  });

  // عدد القطع الكلي في الطلب
  int get quantity => items.fold(0, (sum, item) => sum + item.quantity);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final List items = json['items'] ?? [];
    final List history = json['status_history'] ?? [];
    return OrderModel(
      id: json['id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      status: OrderStatus.fromJson(json['status']),
      items: items.map((item) => OrderItemModel.fromJson(item)).toList(),
      total: json['total'] ?? 0,
      statusHistory: history
          .map((change) => OrderStatusChangeModel.fromJson(change))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'status': status.value,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'status_history': statusHistory.map((change) => change.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// منتج داخل الطلب بسعره وقت الطلب
class OrderItemModel {
  final int productId;
  final String productName;
  final int unitPrice;
  final int quantity;
  final int subtotal;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      unitPrice: json['unit_price'] ?? 0,
      quantity: json['quantity'] ?? 0,
      subtotal: json['subtotal'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}

// تغيير واحد في حالة الطلب
class OrderStatusChangeModel {
  final OrderStatus from;
  final OrderStatus to;
  final int? changedBy;
  final String? note;
  final DateTime? changedAt;

  OrderStatusChangeModel({
    required this.from,
    required this.to,
    this.changedBy,
    this.note,
    this.changedAt,
  });

  factory OrderStatusChangeModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusChangeModel(
      from: OrderStatus.fromJson(json['from']),
      to: OrderStatus.fromJson(json['to']),
      changedBy: json['changed_by'],
      note: json['note'],
      changedAt: json['changed_at'] != null
          ? DateTime.tryParse(json['changed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from.value,
      'to': to.value,
      'changed_by': changedBy,
      'note': note,
      'changed_at': changedAt?.toIso8601String(),
    };
  }
}
