import 'package:mystore/features/authentication/auth_session.dart';
import 'package:mystore/features/products/product_details/product_details_model.dart';
import 'package:get/get.dart';
import 'cart_model.dart';

// سلة الزبون، تعيش طوال تشغيل التطبيق وتُفرغ عند الخروج
class CartController extends GetxController {
  static CartController get to => Get.find<CartController>();

  static const int maxQuantity = 99;

  var items = <CartItemModel>[].obs;

  // عدد القطع الكلي، يظهر على أيقونة السلة
  int get count => items.fold(0, (sum, item) => sum + item.quantity);

  int get total => items.fold(0, (sum, item) => sum + item.subtotal);

  @override
  void onInit() {
    super.onInit();
    // سلة حساب لا تنتقل لحساب آخر يدخل من نفس الجهاز
    ever(AuthSession.to.isLoggedIn, (bool loggedIn) {
      if (!loggedIn) clear();
    });
  }

  // نفس المنتج يُجمع في سطر واحد لأن السيرفر يرفض تكرار المنتج في الطلب
  void add(ProductModel product, int quantity) {
    final int index = _indexOf(product.id);
    if (index == -1) {
      items.add(
        CartItemModel(
          product: product,
          quantity: quantity.clamp(1, maxQuantity),
        ),
      );
    } else {
      final int updated = items[index].quantity + quantity;
      items[index] = items[index].copyWith(
        quantity: updated.clamp(1, maxQuantity),
      );
    }
  }

  void setQuantity(int productId, int quantity) {
    final int index = _indexOf(productId);
    if (index == -1) return;
    if (quantity <= 0) {
      items.removeAt(index);
      return;
    }
    items[index] = items[index].copyWith(
      quantity: quantity.clamp(1, maxQuantity),
    );
  }

  void remove(int productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  void clear() => items.clear();

  int _indexOf(int productId) {
    return items.indexWhere((item) => item.product.id == productId);
  }
}
