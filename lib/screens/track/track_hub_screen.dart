import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'track_overview_screen.dart';
import 'goals_list_screen.dart';
import '../habits/habit_tracker_screen.dart';
import '../progress/hobbies_screen.dart';

class TrackHubScreen extends StatefulWidget {
  const TrackHubScreen({super.key});
  @override
  State<TrackHubScreen> createState() => _TrackHubScreenState();
}

class _TrackHubScreenState extends State<TrackHubScreen> {
  int _index = 0;
  final _labels = const ['Overview', 'Habits', 'Goals', 'Activities'];

  @override
  Widget build(BuildContext context) {
    final screens = const [
      TrackOverviewScreen(),
      HabitTrackerScreen(embedded: true),
      GoalsListScreen(),
      HobbiesScreen(embedded: true),
    ];
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Track', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: List.generate(4, (i) {
                  final selected = i == _index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _index = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        alignment: Alignment.center,
                        child: Text(_labels[i], style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 11)),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: screens[_index]),
        ],
      ),
    );
  }
}