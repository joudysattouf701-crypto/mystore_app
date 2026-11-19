import 'package:mystore/features/products/product_details/product_details_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;

  CartItemModel({required this.product, required this.quantity});

  int get subtotal => product.price * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(product: product, quantity: quantity ?? this.quantity);
  }

  Map<String, dynamic> toJson() {
    return {'product_id': product.id, 'quantity': quantity};
  }
}
