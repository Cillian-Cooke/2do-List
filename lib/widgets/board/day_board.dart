import 'package:flutter/material.dart';

import '../../design.dart';
import '../../models/timeline_entry.dart';
import '../../utils/date_format.dart';
import '../calendar/calendar_view.dart';
import '../entry_form_sheet.dart';
import 'paper_backdrop.dart';

/// The always-visible day: a full sheet of paper and the calendar
/// underneath. Lists live on the glass sheets, not here.
class DayBoard extends StatelessWidget {
  const DayBoard({
    super.key,
    required this.day,
    required this.entries,
    required this.onSelectDay,
    required this.onCreate,
  });

  final DateTime day;
  final List<TimelineEntry> entries;
  final ValueChanged<DateTime> onSelectDay;
  final void Function(TimelineEntry entry) onCreate;

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdayName(day);
    final today = isSameDay(day, DateTime.now());

    return Column(
      children: [
        Expanded(
          child: PaperBackdrop(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weekday,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        height: 1,
                        color: Colors.black.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDate(day)}${today ? '  ·  today' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.52),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Material(
                      color: AppDesign.meColor,
                      shape: const CircleBorder(),
                      elevation: 3,
                      shadowColor: AppDesign.meColor.withValues(alpha: 0.4),
                      child: IconButton(
                        tooltip: 'Add',
                        color: Colors.white,
                        onPressed: () => showEntryFormSheet(
                          context,
                          onCreate: onCreate,
                        ),
                        icon: const Icon(Icons.add),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '← swipe an edge for to-dos →',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.38),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Material(
          color: AppDesign.surface,
          elevation: 8,
          shadowColor: Colors.black26,
          child: SizedBox(
            height: AppDesign.calendarHeight,
            child: CalendarView(
              entries: entries,
              selectedDay: day,
              compact: true,
              onDaySelected: onSelectDay,
            ),
          ),
        ),
      ],
    );
  }
}

String _weekdayName(DateTime day) {
  const names = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return names[day.weekday - 1];
}
