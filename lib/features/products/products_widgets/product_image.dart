import 'package:mystore/core/theme/app_colors.dart';
import 'package:mystore/core/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String url;

  const ProductImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _Placeholder();

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Shimmer(child: SkeletonBox(radius: 0)),
      errorBuilder: (context, error, stackTrace) => const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySoft,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 36,
        color: AppColors.primary,
      ),
    );
  }
}
