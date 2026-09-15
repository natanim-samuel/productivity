import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/misc_widgets.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

class DailyPlannerScreen extends StatelessWidget {
  const DailyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final priorityTasks = state.todayTasks.where((t) => t.priority == Priority.high || t.priority == Priority.medium).toList()
      ..sort((a, b) => (a.priority?.index ?? 9).compareTo(b.priority?.index ?? 9));
    final scheduleTasks = [...state.todayTasks]..sort((a, b) => (a.due ?? now).compareTo(b.due ?? now));
    final habits = state.habits.take(4).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Planner', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 64,
            child: Row(
              children: List.generate(7, (i) {
                final day = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
                final isToday = day.year == now.year && day.month == now.month && day.day == now.day;
                const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(labels[i], style: TextStyle(color: isToday ? Colors.white : AppColors.textSecondary, fontSize: 11)),
                        Text('${day.day}', style: TextStyle(color: isToday ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Top Priorities'),
          AppCard(
            child: priorityTasks.isEmpty
                ? const Text('No high/medium priority tasks today.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                : Column(
              children: [
                for (int i = 0; i < priorityTasks.length; i++) ...[
                  _priorityRow(priorityTasks[i]),
                  if (i != priorityTasks.length - 1) const Divider(height: 20, color: AppColors.divider),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Schedule'),
          AppCard(
            child: scheduleTasks.isEmpty
                ? const Text('Nothing scheduled today.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                : Column(
              children: [
                for (int i = 0; i < scheduleTasks.length; i++) ...[
                  _scheduleRow(context, scheduleTasks[i]),
                  if (i != scheduleTasks.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: 'Habits', actionLabel: '${habits.where((h) => h.isDoneToday).length} / ${habits.length} completed'),
          AppCard(
            child: habits.isEmpty
                ? const Text('No habits yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: habits
                  .map((h) => _HabitIcon(
                icon: h.icon,
                label: h.name,
                done: h.isDoneToday,
                onTap: () => context.read<AppState>().toggleHabitToday(h.id),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priorityRow(Task t) {
    return Row(
      children: [
        Expanded(child: Text(t.title, style: const TextStyle(color: AppColors.textPrimary))),
        if (t.priority != null) PriorityBadge(priority: t.priority!),
      ],
    );
  }

  Widget _scheduleRow(BuildContext context, Task t) {
    final color = t.priority == Priority.high
        ? AppColors.danger
        : t.priority == Priority.medium
        ? AppColors.warning
        : t.isRecurring
        ? AppColors.gold
        : AppColors.primary;
    return GestureDetector(
      onTap: () => context.read<AppState>().toggleTask(t.id),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(t.due != null ? _formatTime(t.due!) : '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: t.completed ? AppColors.surfaceAlt : color.withOpacity(0.85),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                t.title,
                style: TextStyle(
                  color: t.completed ? AppColors.textSecondary : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: t.completed ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
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

class _HabitIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool done;
  final VoidCallback onTap;
  const _HabitIcon({required this.icon, required this.label, required this.done, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? AppColors.success.withOpacity(0.2) : AppColors.surfaceAlt,
              border: Border.all(color: done ? AppColors.success : AppColors.divider),
            ),
            child: Icon(icon, color: done ? AppColors.success : AppColors.textSecondary, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}