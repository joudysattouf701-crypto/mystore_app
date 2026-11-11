import 'package:mystore/features/products/categories/categories_model.dart';

// المنتج كما يرجعه السيرفر (ضمن القائمة وضمن التفاصيل)
class ProductModel {
  final int id;
  final String name;
  final String? description;

  // السعر عدد صحيح بالسنت الأمريكي (37999 = $379.99)، العرض عبر AppMoney
  final int price;
  final CategoryModel? category;
  final String imageUrl;
  final DateTime? createdAt;

  // المخزون يأتي في التفاصيل فقط. null داخل التفاصيل يعني أن المستودع لم يرد
  final int? stock;

  // هل وصل حقل stock أصلاً؟ (منتجات القائمة لا تحتويه)
  final bool hasStockInfo;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.category,
    required this.imageUrl,
    this.createdAt,
    this.stock,
    this.hasStockInfo = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price'] ?? 0,
      category: json['category'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['category'])
          : null,
      imageUrl: json['image_url'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      stock: json['stock'] is int ? json['stock'] : null,
      hasStockInfo: json.containsKey('stock'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category?.toJson(),
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      if (hasStockInfo) 'stock': stock,
    };
  }
}
