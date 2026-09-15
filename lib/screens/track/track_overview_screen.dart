import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/misc_widgets.dart';
import '../../widgets/progress_bars.dart';
import '../../state/app_state.dart';

class TrackOverviewScreen extends StatelessWidget {
  const TrackOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final todayCompleted = state.todayTasks.where((t) => t.completed).map((t) => t.title).toList();
    final latestMilestoneGoal = state.goals.isNotEmpty ? state.goals.reduce((a, b) => a.progress >= b.progress ? a : b) : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Overall Progress', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              Text('Day ${state.dayOfChallenge} of 100', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              AppLinearProgress(value: state.challengeProgress, color: AppColors.gold, height: 10),
              const SizedBox(height: 8),
              Text('${(state.challengeProgress * 100).round()}%', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: StatCard(icon: Icons.local_fire_department, value: '${state.currentStreak}', label: 'day streak', iconColor: AppColors.warning)),
            const SizedBox(width: 10),
            Expanded(child: StatCard(icon: Icons.check_circle, value: '${state.totalCompletedTasks}', label: 'completed', iconColor: AppColors.success)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: StatCard(icon: Icons.timer, value: state.focusTimeLabel, label: 'focus time', iconColor: AppColors.primary)),
            const SizedBox(width: 10),
            Expanded(child: StatCard(icon: Icons.emoji_events, value: '${state.goals.length}', label: 'active goals', iconColor: AppColors.gold)),
          ],
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: "Today's Completions"),
        AppCard(
          child: todayCompleted.isEmpty
              ? const Text('Nothing completed yet today.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: todayCompleted.map((t) => _DoneRow(t)).toList(),
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Habit Streaks'),
        state.habits.isEmpty
            ? const AppCard(child: Text('No habits yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)))
            : AppCard(
          child: Column(
            children: state.habits
                .map((h) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(h.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  Text('${h.streak} days', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ))
                .toList(),
          ),
        ),
        if (latestMilestoneGoal != null) ...[
          const SizedBox(height: 20),
          const SectionHeader(title: 'Top Goal Progress'),
          AppCard(
            child: Row(
              children: [
                Icon(latestMilestoneGoal.icon, color: AppColors.gold, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(latestMilestoneGoal.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      Text('${(latestMilestoneGoal.progress * 100).round()}% complete', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DoneRow extends StatelessWidget {
  final String title;
  const _DoneRow(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: AppColors.success, size: 16),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        ],
      ),
    );
  }
}