import 'package:mystore/features/products/product_details/product_details_model.dart';

// منتج في السلة. السلة محلية على الجهاز فقط وتُرسل عند تأكيد الطلب
class CartItemModel {
  final ProductModel product;
  final int quantity;

  CartItemModel({required this.product, required this.quantity});

  // سعر تقريبي للعرض فقط، السيرفر يحسب السعر الفعلي عند إنشاء الطلب
  int get subtotal => product.price * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(product: product, quantity: quantity ?? this.quantity);
  }

  // شكل العنصر في طلب POST /orders. السيرفر يرفض أي حقل غير هذين
  Map<String, dynamic> toJson() {
    return {'product_id': product.id, 'quantity': quantity};
  }
}
