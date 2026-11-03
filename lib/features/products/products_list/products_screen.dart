import 'package:mystore/core/theme/app_colors.dart';
import 'package:mystore/core/widgets/empty_state.dart';
import 'package:mystore/core/widgets/skeleton.dart';
import 'package:mystore/features/authentication/auth_session.dart';
import 'package:mystore/features/products/product_details/product_details_screen.dart';
import 'package:mystore/features/products/products_widgets/category_chips.dart';
import 'package:mystore/features/products/products_widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'products_controller.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductsController controller = Get.put(ProductsController());

  static const SliverGridDelegate _gridDelegate =
      SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.68,
      );

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < 400) controller.loadMore();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: Obx(
              () => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  if (controller.categories.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CategoryChips(
                          categories: controller.categories,
                          selectedId: controller.selectedCategoryId.value,
                          onSelected: controller.selectCategory,
                        ),
                      ),
                    ),
                  ..._buildContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final String name = AuthSession.to.user.value?.name ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'أهلاً بك' : 'أهلاً، $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ماذا تريد أن تشتري اليوم؟',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.surface,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.border),
            ),
            child: IconButton(
              tooltip: 'تسجيل الخروج',
              onPressed: AuthSession.to.logout,
              icon: const Icon(
                Icons.logout_rounded,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContent() {
    if (controller.isLoading.value && controller.products.isEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: _gridDelegate,
            delegate: SliverChildBuilderDelegate(
              (context, index) => const Shimmer(child: ProductCardSkeleton()),
              childCount: 6,
            ),
          ),
        ),
      ];
    }

    final String? error = controller.errorMessage.value;
    if (error != null && controller.products.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorState(message: error, onRetry: controller.refreshAll),
        ),
      ];
    }

    if (controller.products.isEmpty) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'لا توجد منتجات',
            message: 'لم تُضف منتجات هنا بعد، تفقّد المتجر لاحقاً',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: _gridDelegate,
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = controller.products[index];
            return ProductCard(
              product: product,
              onTap: () => Get.to(
                () => ProductDetailsScreen(
                  productId: product.id,
                  initial: product,
                ),
              ),
            );
          }, childCount: controller.products.length),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: controller.isLoadingMore.value
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    ];
  }
}
