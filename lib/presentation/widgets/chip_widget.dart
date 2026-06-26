import 'package:flutter/material.dart';
import 'package:neopoker/core/constants/app_colors.dart';

class ChipWidget extends StatelessWidget {
  final int amount;
  final double size;

  const ChipWidget({
    super.key,
    required this.amount,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.neonCyan.withValues(alpha: 0.3),
            AppColors.neonCyan.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '$amount',
          style: TextStyle(
            color: AppColors.neonCyan,
            fontSize: size * 0.3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
