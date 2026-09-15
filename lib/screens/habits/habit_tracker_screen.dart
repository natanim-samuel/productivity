import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/misc_widgets.dart';
import '../../widgets/streak_grid.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../track/add_activity_screen.dart';
import 'goal_details_screen.dart';

class HabitTrackerScreen extends StatelessWidget {
  /// When embedded inside TrackHubScreen, the hub already renders the
  /// "Track" title and tab switcher, so this screen skips its own header.
  final bool embedded;
  const HabitTrackerScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<AppState>().habits;

    final content = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (!embedded)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Habit Tracker', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () {
                  final goals = context.read<AppState>().goals;
                  if (goals.isNotEmpty) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => GoalDetailsScreen(goalId: goals.first.id)));
                  }
                },
                child: const Icon(Icons.flag_outlined, color: AppColors.textSecondary),
              ),
            ],
          ),
        if (!embedded) const SizedBox(height: 20),
        if (habits.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No habits yet — tap "Add Habit" below to start one.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
        for (int i = 0; i < habits.length; i++) ...[
          _habitCard(context, habits[i]),
          if (i != habits.length - 1) const SizedBox(height: 14),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddActivityScreen(isHabit: true))),
            icon: const Icon(Icons.add),
            label: const Text('Add Habit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
    return embedded ? content : SafeArea(child: content);
  }

  Widget _habitCard(BuildContext context, Habit h) {
    final states = h.weekStates().map((s) {
      switch (s) {
        case 'done':
          return DayState.done;
        case 'future':
          return DayState.future;
        default:
          return DayState.missed;
      }
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(h.icon, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(h.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                ],
              ),
              Text('${h.streak} day streak', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          WeekStreakRow(
            days: states,
            onTapDay: (_) => context.read<AppState>().toggleHabitToday(h.id),
            tappableIndex: DateTime.now().weekday - 1, // 0=Mon..6=Sun, matches weekStates() ordering
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Tap today to mark it done', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 10)),
          ),
        ],
      ),
    );
  }
}