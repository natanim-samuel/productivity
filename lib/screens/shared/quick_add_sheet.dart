import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'add_quick_item_screen.dart';
import '../track/add_activity_screen.dart';

/// Call this from anywhere to open the "what do you want to add" sheet.
void showQuickAddSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _QuickAddSheet(),
  );
}

class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 20),
          const Text('What would you like to add?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _option(context, Icons.checklist, 'Task', AppColors.primary, () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const AddQuickItemScreen(kind: QuickItemKind.task)))),
              _option(context, Icons.local_fire_department, 'Habit', AppColors.success, () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const AddActivityScreen(isHabit: true)))),
              _option(context, Icons.flag, 'Goal', AppColors.gold, () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const AddQuickItemScreen(kind: QuickItemKind.goal)))),
              _option(context, Icons.timer, 'Activity', AppColors.warning, () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const AddActivityScreen(isHabit: false)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(); // close the sheet first
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
        ],
      ),
    );
  }
}