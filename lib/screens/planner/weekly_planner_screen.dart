import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/misc_widgets.dart';
import '../../state/app_state.dart';

class WeeklyPlannerScreen extends StatelessWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final goalsThisWeek = state.goals.where((g) => g.due != null && !g.due!.isBefore(weekStart) && !g.due!.isAfter(weekEnd)).toList();
    final displayGoals = goalsThisWeek.isNotEmpty ? goalsThisWeek : state.goals;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              Text(
                '${_fmt(weekStart)} – ${_fmt(weekEnd)}',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
              ),
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
                  _goalRow(displayGoals[i].title, displayGoals[i].progress),
                  if (i != displayGoals.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'This Week by Activity'),
          AppCard(
            child: state.activities.isEmpty
                ? const Text('No activities logged yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                : Column(
              children: [
                for (int i = 0; i < state.activities.length; i++) ...[
                  _hoursRow(state.activities[i].icon, state.activities[i].name, state.activities[i].minutesThisWeekLabel, AppColors.primary),
                  if (i != state.activities.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Habit Check-in'),
          AppCard(
            child: state.habits.isEmpty
                ? const Text('No habits yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                : Column(
              children: state.habits
                  .map((h) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(h.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                    Text('${h.streak}-day streak', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }

  Widget _goalRow(String title, double progress) {
    return Row(
      children: [
        Icon(progress >= 1 ? Icons.check_circle : Icons.radio_button_unchecked, color: progress >= 1 ? AppColors.success : AppColors.divider, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
        Text('${(progress * 100).round()}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _hoursRow(IconData icon, String title, String timeLabel, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
        Text(timeLabel, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}