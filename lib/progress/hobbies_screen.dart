import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/misc_widgets.dart';
import '../../widgets/progress_bars.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../track/add_activity_screen.dart';

class HobbiesScreen extends StatelessWidget {
  /// When embedded inside TrackHubScreen the hub already shows the "Track"
  /// title and tab switcher, so this skips its own header.
  final bool embedded;
  const HobbiesScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final activities = context.watch<AppState>().activities;
    final totalMinutes = activities.fold<int>(0, (sum, a) => sum + a.minutesThisWeek);
    final totalLabel = totalMinutes < 60 ? '${totalMinutes}m' : '${totalMinutes ~/ 60}h ${totalMinutes % 60}m';

    final content = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (!embedded)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Activities', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddActivityScreen())),
                child: const Icon(Icons.add, color: AppColors.primary),
              ),
            ],
          ),
        if (!embedded) const SizedBox(height: 16),
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('This Week — Total Time', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(totalLabel, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                ],
              ),
              Icon(Icons.timer, color: AppColors.primary.withOpacity(0.5), size: 32),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (activities.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No activities yet — add one below.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
        for (final a in activities) ...[
          _activityCard(context, a),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddActivityScreen())),
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: const Text('Add Activity', style: TextStyle(color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
    return embedded ? content : SafeArea(child: content);
  }

  Widget _activityCard(BuildContext context, Activity a) {
    const color = AppColors.primary;
    return AppCard(
      child: InkWell(
        onTap: () => _showLogSessionDialog(context, a),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(a.icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(a.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      Text('${(a.weeklyProgress * 100).round()}%', style: const TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(a.minutesThisWeekLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  const SizedBox(height: 6),
                  AppLinearProgress(value: a.weeklyProgress, color: color, height: 6),
                  const SizedBox(height: 4),
                  Text(a.goalLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.add_circle_outline, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLogSessionDialog(BuildContext context, Activity activity) {
    final controller = TextEditingController(text: '30');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Log time — ${activity.name}', style: const TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Minutes', hintStyle: TextStyle(color: AppColors.textSecondary)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () {
              final minutes = int.tryParse(controller.text.trim());
              if (minutes != null && minutes > 0) {
                context.read<AppState>().logActivityMinutes(activity.id, minutes);
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Log', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}