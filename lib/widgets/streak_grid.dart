import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A row of 7 day-cells (M..S), each either done / missed / future.
enum DayState { done, missed, future }

class WeekStreakRow extends StatelessWidget {
  final List<DayState> days; // length 7
  final Color doneColor;
  final ValueChanged<int>? onTapDay; // index 0..6, only meaningful for the tappable day (usually "today")
  final int? tappableIndex;
  const WeekStreakRow({super.key, required this.days, this.doneColor = AppColors.success, this.onTapDay, this.tappableIndex});

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final state = days[i];
        Color bg;
        Widget child;
        switch (state) {
          case DayState.done:
            bg = doneColor;
            child = const Icon(Icons.check, size: 14, color: Colors.white);
            break;
          case DayState.missed:
            bg = AppColors.surfaceAlt;
            child = const Icon(Icons.remove, size: 14, color: AppColors.textSecondary);
            break;
          case DayState.future:
            bg = Colors.transparent;
            child = Text(_labels[i], style: const TextStyle(color: AppColors.textSecondary, fontSize: 11));
        }
        final isTappable = onTapDay != null && tappableIndex == i;
        Border? border;
        if (isTappable) {
          border = Border.all(color: AppColors.gold, width: 2);
        } else if (state == DayState.future) {
          border = Border.all(color: AppColors.divider);
        }
        final cell = Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: border),
          alignment: Alignment.center,
          child: child,
        );
        return Column(
          children: [
            isTappable ? GestureDetector(onTap: () => onTapDay!(i), child: cell) : cell,
            const SizedBox(height: 4),
            Text(_labels[i], style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          ],
        );
      }),
    );
  }
}

/// Month grid of numbered day cells, colored by completion level (0..1).
class MonthCompletionGrid extends StatelessWidget {
  final int daysInMonth;
  final Map<int, double> completionByDay; // day -> 0..1
  final int? highlightDay;
  const MonthCompletionGrid({super.key, required this.daysInMonth, required this.completionByDay, this.highlightDay});

  Color _colorFor(double v) {
    if (v >= 0.8) return AppColors.success;
    if (v >= 0.4) return AppColors.gold;
    if (v > 0) return AppColors.primaryDim;
    return AppColors.surfaceAlt;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: daysInMonth,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, i) {
        final day = i + 1;
        final v = completionByDay[day] ?? 0;
        final isHighlighted = day == highlightDay;
        return Container(
          decoration: BoxDecoration(
            color: _colorFor(v),
            shape: BoxShape.circle,
            border: isHighlighted ? Border.all(color: AppColors.gold, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: Text('$day', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        );
      },
    );
  }
}