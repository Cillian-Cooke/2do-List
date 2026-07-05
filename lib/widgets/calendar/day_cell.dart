import 'package:flutter/material.dart';

import '../../design.dart';

/// One square in the calendar grid. Darkens toward [hue] as [count]
/// approaches [maxCount] for the visible month, GitHub/BeReal
/// contribution-graph style. [hue] is pink/blue/purple depending on whose
/// entries land on this day (see CalendarView._hueFor). Tapping it reports
/// the day.
class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.day,
    required this.count,
    required this.maxCount,
    required this.hue,
    required this.isToday,
    required this.onTap,
  });

  final int day;
  final int count;
  final int maxCount;
  final Color hue;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final intensity = maxCount == 0 ? 0.0 : (count / maxCount).clamp(0.0, 1.0);
    final background = count == 0
        ? scheme.surfaceContainerHighest
        : Color.lerp(hue.withValues(alpha: 0.18), hue, intensity);
    final textColor = count > 0 && intensity > 0.55 ? Colors.white : null;

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
              border: isToday ? Border.all(color: scheme.primary, width: 2) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
