import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/misc_widgets.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../shared/quick_add_sheet.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _tab = 0;
  final _tabs = const ['Today', 'Upcoming', 'Overdue', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Tasks', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              Icon(Icons.search, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(_tabs.length, (i) {
              final selected = i == _tab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(_tabs[i], style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 11)),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          ..._buildTabContent(state),
          const SizedBox(height: 20),
          const Text('Recurring', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 10),
          state.recurringTasks.isEmpty
              ? const AppCard(child: Text('No recurring items yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)))
              : AppCard(
            child: Column(
              children: [
                for (int i = 0; i < state.recurringTasks.length; i++) ...[
                  _recurringRow(state.recurringTasks[i]),
                  if (i != state.recurringTasks.length - 1) const Divider(height: 24, color: AppColors.divider),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => showQuickAddSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTabContent(AppState state) {
    switch (_tab) {
      case 0:
        return _buildToday(state);
      case 1:
        return [_simpleTaskList(state.upcomingTasks, AppColors.primary, emptyText: 'Nothing upcoming.')];
      case 2:
        return [_simpleTaskList(state.overdueTasks, AppColors.danger, emptyText: 'Nothing overdue — nice.')];
      case 3:
        return [_simpleTaskList(state.completedTasks, AppColors.success, emptyText: 'Nothing completed yet.')];
      default:
        return [];
    }
  }

  Widget _simpleTaskList(List<Task> items, Color dot, {required String emptyText}) {
    if (items.isEmpty) {
      return AppCard(child: Text(emptyText, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)));
    }
    return AppCard(
      child: Column(
        children: items
            .map((t) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: CheckableRow(
            title: t.title,
            subtitle: t.due != null ? _formatDue(t.due!) : null,
            checked: t.completed,
            checkColor: dot,
            onChanged: (_) => context.read<AppState>().toggleTask(t.id),
          ),
        ))
            .toList(),
      ),
    );
  }

  List<Widget> _buildToday(AppState state) {
    final byPriority = <Priority, List<Task>>{Priority.high: [], Priority.medium: [], Priority.low: []};
    for (final t in state.todayTasks) {
      if (t.priority != null) byPriority[t.priority]!.add(t);
    }
    final colors = {Priority.high: AppColors.danger, Priority.medium: AppColors.warning, Priority.low: AppColors.success};
    final widgets = <Widget>[];
    bool anyShown = false;
    for (final p in Priority.values) {
      final items = byPriority[p]!;
      if (items.isEmpty) continue;
      anyShown = true;
      widgets.add(_prioritySection('${_label(p)} Priority', items, colors[p]!));
      widgets.add(const SizedBox(height: 20));
    }
    if (!anyShown) {
      widgets.add(const AppCard(child: Text('No tasks due today.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))));
    }
    return widgets;
  }

  String _label(Priority p) => p == Priority.high ? 'High' : p == Priority.medium ? 'Medium' : 'Low';

  Widget _prioritySection(String title, List<Task> items, Color dot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            children: items
                .map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: CheckableRow(
                title: t.title,
                subtitle: t.due != null ? _formatDue(t.due!) : null,
                checked: t.completed,
                checkColor: dot,
                onChanged: (_) => context.read<AppState>().toggleTask(t.id),
              ),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _recurringRow(Task t) {
    return Row(
      children: [
        const Icon(Icons.replay, color: AppColors.gold, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
              Text(t.recurrenceLabel ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
        const Icon(Icons.notifications, color: AppColors.textSecondary, size: 16),
      ],
    );
  }

  String _formatDue(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.month}/${d.day} · $hour:$minute $period';
  }
}