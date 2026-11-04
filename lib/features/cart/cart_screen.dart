import 'package:mystore/core/theme/app_colors.dart';
import 'package:mystore/core/utils/app_money.dart';
import 'package:mystore/core/widgets/app_button.dart';
import 'package:mystore/core/widgets/empty_state.dart';
import 'package:mystore/features/orders/create_order/create_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cart_controller.dart';
import 'cart_widgets/cart_item_tile.dart';

// السلة: مراجعة المنتجات والكميات ثم تأكيد الطلب
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController cart = CartController.to;
  final CreateOrderController controller = Get.put(CreateOrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السلة'),
        actions: [
          Obx(
            () => cart.items.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: _confirmClear,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('إفراغ'),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (cart.items.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'سلتك فارغة',
            message: 'أضف منتجات من المتجر ثم عد إلى هنا لإتمام طلبك',
            action: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('تصفّح المنتجات'),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          itemCount: cart.items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = cart.items[index];
            return CartItemTile(
              item: item,
              onQuantityChanged: (quantity) =>
                  cart.setQuantity(item.product.id, quantity),
              onRemove: () => cart.remove(item.product.id),
            );
          },
        );
      }),
      bottomNavigationBar: Obx(
        () => cart.items.isEmpty ? const SizedBox.shrink() : _buildSummary(),
      ),
    );
  }

  Widget _buildSummary() {
    final int count = cart.count;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  count == 1 ? 'قطعة واحدة' : '$count قطع',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  AppMoney.format(cart.total),
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'المجموع تقريبي، ويُحتسب السعر النهائي عند تأكيد الطلب',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 14),
            AppButton(
              label: 'تأكيد الطلب',
              isLoading: controller.isLoading.value,
              onPressed: controller.submit,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear() {
    Get.dialog(
      AlertDialog(
        title: const Text('إفراغ السلة'),
        content: const Text('هل تريد حذف كل المنتجات من السلة؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Get.back();
              cart.clear();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('إفراغ'),
          ),
        ],
      ),
    );
  }
}
