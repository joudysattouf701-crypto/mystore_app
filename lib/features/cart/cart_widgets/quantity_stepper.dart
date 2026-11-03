import 'package:mystore/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// زر زيادة وإنقاص الكمية. compact للنسخة الصغيرة داخل بطاقة السلة
class QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool compact;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 34 : 54;

    return Container(
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(compact ? 10 : 14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            size,
            Icons.add_rounded,
            value < max ? () => onChanged(value + 1) : null,
          ),
          SizedBox(
            width: compact ? 26 : 34,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 14 : 16,
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buildButton(
            size,
            Icons.remove_rounded,
            value > min ? () => onChanged(value - 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(double size, IconData icon, VoidCallback? onPressed) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        color: AppColors.text,
        disabledColor: AppColors.border,
        icon: Icon(icon, size: compact ? 16 : 20),
      ),
    );
  }
}
