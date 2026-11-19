import 'package:mystore/core/theme/app_colors.dart';
import 'package:mystore/features/products/categories/categories_model.dart';
import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildChip('الكل', null),
          for (final category in categories)
            _buildChip(category.name, category.id),
        ],
      ),
    );
  }

  Widget _buildChip(String label, int? id) {
    final bool selected = selectedId == id;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: () => onSelected(id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: selected ? Colors.white : AppColors.text,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
