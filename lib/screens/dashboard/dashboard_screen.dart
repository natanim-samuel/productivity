import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/misc_widgets.dart';
import '../../widgets/progress_bars.dart';
import '../../state/app_state.dart';
import '../more/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final todayTasks = state.todayTasks;
    final doneCount = todayTasks.where((t) => t.completed).length;
    final nextReminder = state.recurringTasks.isNotEmpty ? state.recurringTasks.first : null;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good morning,', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text('Natanim 👋', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                child: const CircleAvatar(radius: 22, backgroundColor: AppColors.surfaceAlt, child: Icon(Icons.person, color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('100-Day Challenge', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    Text('${(state.challengeProgress * 100).round()}%', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Day ${state.dayOfChallenge} of 100', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 12),
                AppLinearProgress(value: state.challengeProgress, color: AppColors.gold),
                const SizedBox(height: 10),
                const Text('Keep going! You\'re doing great.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: StatCard(icon: Icons.local_fire_department, value: '${state.currentStreak}', label: 'day streak', iconColor: AppColors.warning)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(icon: Icons.check_circle, value: '${state.totalCompletedTasks}', label: 'completed', iconColor: AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(icon: Icons.timer, value: state.focusTimeLabel, label: 'focus time', iconColor: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(title: "Today's Plan", actionLabel: '$doneCount / ${todayTasks.length} done'),
          AppCard(
            child: todayTasks.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Nothing due today. Add a task from the + button below.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            )
                : Column(
              children: todayTasks
                  .map((t) => CheckableRow(
                title: t.title,
                subtitle: t.due != null ? _formatTime(t.due!) : null,
                checked: t.completed,
                onChanged: (_) => context.read<AppState>().toggleTask(t.id),
              ))
                  .toList(),
            ),
          ),
          if (nextReminder != null) ...[
            const SizedBox(height: 16),
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: AppColors.gold),
                  const SizedBox(width: 12),
                  Expanded(child: Text(nextReminder.title, style: const TextStyle(color: AppColors.textPrimary))),
                  Text(nextReminder.recurrenceLabel ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}