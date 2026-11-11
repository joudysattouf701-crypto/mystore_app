import 'package:mystore/core/theme/app_colors.dart';
import 'package:mystore/core/utils/app_money.dart';
import 'package:mystore/core/utils/app_snackbar.dart';
import 'package:mystore/core/widgets/empty_state.dart';
import 'package:mystore/features/cart/cart_controller.dart';
import 'package:mystore/features/cart/cart_screen.dart';
import 'package:mystore/features/cart/cart_widgets/cart_badge.dart';
import 'package:mystore/features/cart/cart_widgets/quantity_stepper.dart';
import 'package:mystore/features/products/products_widgets/product_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_details_controller.dart';
import 'product_details_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  // نسخة المنتج من القائمة لعرضها فوراً قبل وصول التفاصيل
  final ProductModel? initial;

  const ProductDetailsScreen({super.key, required this.productId, this.initial});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // tag برقم المنتج حتى لا تتشارك شاشتا تفاصيل نفس الـ controller
  late final ProductDetailsController controller = Get.put(
    ProductDetailsController(
      productId: widget.productId,
      initial: widget.initial,
    ),
    tag: '${widget.productId}',
  );

  // الكمية المختارة قبل الإضافة للسلة
  int _quantity = 1;

  void _addToCart(ProductModel product) {
    CartController.to.add(product, _quantity);
    setState(() => _quantity = 1);
    AppSnackbar.success('أضفنا ${product.name} إلى السلة');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: Obx(() {
        final ProductModel? product = controller.product.value;
        if (product == null || controller.notFound.value) {
          return const SizedBox.shrink();
        }
        return _buildBottomBar(product);
      }),
      body: Obx(() {
        if (controller.notFound.value) {
          return _buildMessage(
            const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'المنتج غير موجود',
              message: 'ربما حُذف هذا المنتج أو لم يعد متاحاً',
            ),
          );
        }

        final ProductModel? product = controller.product.value;
        if (product != null) return _buildDetails(product);

        final String? error = controller.errorMessage.value;
        if (error != null) {
          return _buildMessage(
            ErrorState(message: error, onRetry: controller.fetchProduct),
          );
        }

        return const Center(child: CircularProgressIndicator());
      }),
    );
  }

  // رسالة في منتصف الشاشة مع زر رجوع في الأعلى
  Widget _buildMessage(Widget child) {
    return SafeArea(
      child: Column(
        children: [
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(padding: EdgeInsets.all(8), child: _RoundButton()),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildDetails(ProductModel product) {
    final String description = product.description?.trim() ?? '';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 340,
          pinned: true,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: const Padding(
            padding: EdgeInsets.all(8),
            child: _RoundButton(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: CartBadge(
                child: _RoundButton(
                  icon: Icons.shopping_bag_outlined,
                  tooltip: 'السلة',
                  onPressed: () => Get.to(() => const CartScreen()),
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'product-${product.id}',
              child: ProductImage(url: product.imageUrl),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.category != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category!.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppMoney.format(product.price),
                  style: const TextStyle(
                    fontSize: 22,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (product.hasStockInfo) ...[
                  const SizedBox(height: 8),
                  _buildStock(product.stock),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: AppColors.border, height: 1),
                ),
                const Text(
                  'الوصف',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description.isEmpty
                      ? 'لا يوجد وصف لهذا المنتج'
                      : description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // الكمية المتوفرة. null يعني أن المستودع لم يرد، والصفحة تبقى شغّالة
  Widget _buildStock(int? stock) {
    final String text;
    final Color color;
    if (stock == null) {
      text = 'الكمية غير متاحة حالياً';
      color = AppColors.textMuted;
    } else if (stock <= 0) {
      text = 'نفدت الكمية';
      color = Colors.red;
    } else {
      text = 'الكمية المتوفرة: $stock';
      color = Colors.green.shade700;
    }

    return Text(
      text,
      style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600),
    );
  }

  // شريط ثابت في الأسفل: اختيار الكمية وزر الإضافة للسلة
  Widget _buildBottomBar(ProductModel product) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            QuantityStepper(
              value: _quantity,
              max: CartController.maxQuantity,
              onChanged: (quantity) => setState(() => _quantity = quantity),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addToCart(product),
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                label: const Text('أضف إلى السلة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// زر دائري أبيض يظهر بوضوح فوق الصورة، وهو زر الرجوع افتراضياً
class _RoundButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;

  const _RoundButton({
    this.icon = Icons.arrow_back,
    this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed ?? () => Get.back(),
        icon: Icon(icon, color: AppColors.text, size: 20),
      ),
    );
  }
}
