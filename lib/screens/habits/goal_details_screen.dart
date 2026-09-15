import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/progress_bars.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

class GoalDetailsScreen extends StatelessWidget {
  final String goalId;
  const GoalDetailsScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final goal = state.goalById(goalId);

    if (goal == null) {
      return const Scaffold(backgroundColor: AppColors.bg, body: Center(child: Text('Goal not found', style: TextStyle(color: AppColors.textSecondary))));
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.arrow_back, color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                const Text('Goal Details', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), shape: BoxShape.circle),
                        child: Icon(goal.icon, color: AppColors.gold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(goal.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppLinearProgress(value: goal.progress, color: AppColors.gold, height: 8),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(goal.progress * 100).round()}%', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
                      Text(goal.due != null ? 'Due: ${goal.due!.month}/${goal.due!.day}/${goal.due!.year}' : 'No due date',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            if (goal.description.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('About this goal', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(goal.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            const Text('Sub Goals', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            goal.subGoals.isEmpty
                ? const AppCard(child: Text('No sub-goals yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)))
                : AppCard(
              child: Column(
                children: [
                  for (int i = 0; i < goal.subGoals.length; i++) ...[
                    _subGoalRow(context, goal.id, goal.subGoals[i]),
                    if (i != goal.subGoals.length - 1) const Divider(height: 24, color: AppColors.divider),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAddSubGoalDialog(context, goal.id),
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: const Text('Add Sub Goal', style: TextStyle(color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subGoalRow(BuildContext context, String goalId, SubGoal subGoal) {
    return GestureDetector(
      onTap: () => context.read<AppState>().toggleSubGoal(goalId, subGoal.id),
      child: Row(
        children: [
          Icon(subGoal.done ? Icons.check_circle : Icons.radio_button_unchecked, color: subGoal.done ? AppColors.success : AppColors.divider, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(subGoal.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
        ],
      ),
    );
  }

  void _showAddSubGoalDialog(BuildContext context, String goalId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Add Sub Goal', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'e.g. Write tests', hintStyle: TextStyle(color: AppColors.textSecondary)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<AppState>().addSubGoal(goalId, controller.text.trim());
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Add', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}