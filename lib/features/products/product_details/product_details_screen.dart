import 'package:mystore/core/theme/app_colors.dart';
import 'package:mystore/core/utils/app_money.dart';
import 'package:mystore/core/widgets/empty_state.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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
}

// زر رجوع دائري أبيض يظهر بوضوح فوق الصورة
class _RoundButton extends StatelessWidget {
  const _RoundButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back, color: AppColors.text, size: 20),
      ),
    );
  }
}
