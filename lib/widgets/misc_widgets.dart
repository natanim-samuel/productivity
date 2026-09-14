import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class PriorityBadge extends StatelessWidget {
  final Priority priority;
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final map = {
      Priority.high: (AppColors.danger, 'High'),
      Priority.medium: (AppColors.warning, 'Medium'),
      Priority.low: (AppColors.success, 'Low'),
    };
    final (color, label) = map[priority]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  const StatCard({super.key, required this.icon, required this.value, required this.label, this.iconColor = AppColors.gold});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAdd;
  final String? actionLabel;
  const SectionHeader({super.key, required this.title, this.onAdd, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (onAdd != null)
            GestureDetector(
              onTap: onAdd,
              child: actionLabel != null
                  ? Text(actionLabel!, style: const TextStyle(color: AppColors.primary, fontSize: 13))
                  : const Icon(Icons.add, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}

class CheckableRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool checked;
  final ValueChanged<bool?>? onChanged;
  final Color checkColor;
  const CheckableRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.checked,
    this.onChanged,
    this.checkColor = AppColors.success,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged?.call(!checked),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: checked ? checkColor : Colors.transparent,
                border: Border.all(color: checked ? checkColor : AppColors.divider, width: 2),
              ),
              child: checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: checked ? AppColors.textSecondary : AppColors.textPrimary,
                    decoration: checked ? TextDecoration.lineThrough : null,
                    fontSize: 14,
                  ),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}