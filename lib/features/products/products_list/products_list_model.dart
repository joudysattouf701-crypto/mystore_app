import 'package:mystore/core/models/pagination_meta.dart';
import 'package:mystore/features/products/product_details/product_details_model.dart';

// صفحة واحدة من قائمة المنتجات. الرد: { data: [Product], meta: {...} }
class ProductsListModel {
  final List<ProductModel> products;
  final PaginationMeta meta;

  ProductsListModel({required this.products, required this.meta});

  factory ProductsListModel.fromJson(Map<String, dynamic> json) {
    final List data = json['data'] ?? [];
    return ProductsListModel(
      products: data.map((item) => ProductModel.fromJson(item)).toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': products.map((product) => product.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}
