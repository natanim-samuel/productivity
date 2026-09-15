import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'daily_planner_screen.dart';
import 'weekly_planner_screen.dart';
import 'monthly_planner_screen.dart';

class PlannerHubScreen extends StatefulWidget {
  const PlannerHubScreen({super.key});
  @override
  State<PlannerHubScreen> createState() => _PlannerHubScreenState();
}

class _PlannerHubScreenState extends State<PlannerHubScreen> {
  int _index = 0;
  final _labels = const ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    final screens = [const DailyPlannerScreen(), const WeeklyPlannerScreen(), const MonthlyPlannerScreen()];
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: List.generate(3, (i) {
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
                        child: Text(_labels[i], style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 13)),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        Expanded(child: screens[_index]),
      ],
    );
  }
}