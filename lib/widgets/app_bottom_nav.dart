import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;
  const AppBottomNav({super.key, required this.currentIndex, required this.onTap, required this.onAddTap});

  // Two tabs on the left of the center Add button, two on the right.
  static const _leftItems = [
    (Icons.home_rounded, 'Home'),
    (Icons.calendar_month_rounded, 'Planner'),
  ];
  static const _rightItems = [
    (Icons.bar_chart_rounded, 'Track'),
    (Icons.checklist_rounded, 'Tasks'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ..._buildTabs(_leftItems, startIndex: 0),
          _buildAddButton(),
          ..._buildTabs(_rightItems, startIndex: 2),
        ],
      ),
    );
  }

  List<Widget> _buildTabs(List<(IconData, String)> items, {required int startIndex}) {
    return List.generate(items.length, (i) {
      final index = startIndex + i;
      final selected = index == currentIndex;
      final (icon, label) = items[i];
      final color = selected ? AppColors.primary : AppColors.textSecondary;
      return GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      );
    });
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAddTap,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: const Offset(0, -14),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold,
            boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.add, color: AppColors.bg, size: 28),
        ),
      ),
    );
  }
}