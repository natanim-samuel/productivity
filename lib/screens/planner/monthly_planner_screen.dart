import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/misc_widgets.dart';
import '../../widgets/progress_bars.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

class MonthlyPlannerScreen extends StatelessWidget {
  const MonthlyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final daysElapsed = now.day;

    final goalsThisMonth = state.goals.where((g) => g.due != null && !g.due!.isBefore(monthStart) && !g.due!.isAfter(monthEnd)).toList();
    final displayGoals = goalsThisMonth.isNotEmpty ? goalsThisMonth : state.goals;

    final completedThisMonth = state.tasks
        .where((t) => t.completed && t.due != null && t.due!.year == now.year && t.due!.month == now.month)
        .map((t) => t.title)
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              Text(_monthLabel(now), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Goals'),
          AppCard(
            child: displayGoals.isEmpty
                ? const Text('No goals yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                : Column(
              children: [
                for (int i = 0; i < displayGoals.length; i++) ...[
                  LabelledProgress(label: displayGoals[i].title, value: displayGoals[i].progress),
                  if (i != displayGoals.length - 1) const SizedBox(height: 14),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Important Dates'),
          AppCard(
            child: displayGoals.where((g) => g.due != null).isEmpty
                ? const Text('No upcoming dates.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                : Column(
              children: [
                for (final g in displayGoals.where((g) => g.due != null))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _dateRow(AppColors.gold, g.title, '${g.due!.month}/${g.due!.day}/${g.due!.year}'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Monthly Habits'),
          AppCard(
            child: state.habits.isEmpty
                ? const Text('No habits yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: state.habits.take(4).map((h) => _MiniRing(habit: h, daysElapsed: daysElapsed)).toList(),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: "This Month's Completions"),
          AppCard(
            child: completedThisMonth.isEmpty
                ? const Text('Nothing completed yet this month.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                : Column(
              children: completedThisMonth.map((t) => _bullet(t)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime d) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[d.month - 1]} ${d.year}';
  }

  Widget _dateRow(Color color, String title, String date) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
        Text(date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
        ],
      ),
    );
  }
}

class _MiniRing extends StatelessWidget {
  final Habit habit;
  final int daysElapsed;
  const _MiniRing({required this.habit, required this.daysElapsed});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int doneCount = 0;
    for (int d = 1; d <= daysElapsed; d++) {
      if (habit.isDoneOn(DateTime(now.year, now.month, d))) doneCount++;
    }
    final ratio = daysElapsed == 0 ? 0.0 : (doneCount / daysElapsed).clamp(0, 1).toDouble();

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AppCircularProgress(value: ratio, centerLabel: '', size: 52, color: AppColors.primary),
            Icon(habit.icon, color: AppColors.primary, size: 18),
          ],
        ),
        const SizedBox(height: 6),
        Text(habit.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11)),
        Text('$doneCount/$daysElapsed', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}