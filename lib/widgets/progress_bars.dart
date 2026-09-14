import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLinearProgress extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final double height;
  const AppLinearProgress({super.key, required this.value, this.color = AppColors.primary, this.height = 8});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: AppColors.surfaceAlt,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

/// Labelled row: title, % on the right, bar underneath.
class LabelledProgress extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String? trailingText;
  const LabelledProgress({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.primary,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              trailingText ?? '${(value * 100).round()}%',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AppLinearProgress(value: value, color: color),
      ],
    );
  }
}

class AppCircularProgress extends StatelessWidget {
  final double value; // 0..1
  final String centerLabel;
  final double size;
  final Color color;
  const AppCircularProgress({
    super.key,
    required this.value,
    required this.centerLabel,
    this.size = 64,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value.clamp(0, 1),
              strokeWidth: 6,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(centerLabel, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}