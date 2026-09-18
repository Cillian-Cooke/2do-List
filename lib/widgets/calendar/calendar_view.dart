import 'package:flutter/material.dart';

import '../../models/timeline_entry.dart';
import '../../utils/date_format.dart';
import 'day_cell.dart';

const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

class _DayStat {
  int count = 0;
  bool hasMe = false;
  bool hasPartner = false;
}

/// A one-month calendar grid, shaded per day by how many entries occur
/// that day, tinted pink/blue/purple by whose entries they are. Tapping a
/// day reports it via [onDaySelected].
class CalendarView extends StatefulWidget {
  const CalendarView({
    super.key,
    required this.entries,
    required this.onDaySelected,
    this.selectedDay,
    this.compact = false,
  });

  final List<TimelineEntry> entries;
  final void Function(DateTime day) onDaySelected;
  final DateTime? selectedDay;
  final bool compact;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  Map<DateTime, _DayStat> _statsByDay() {
    final stats = <DateTime, _DayStat>{};
    for (final entry in widget.entries) {
      final start = entry.startDate;
      if (start == null) continue;

      var day = dateOnly(start);
      final end = dateOnly(entry.endDate ?? start);
      var guard = 0;
      while (!day.isAfter(end) && guard < 366) {
        final stat = stats.putIfAbsent(day, () => _DayStat());
        stat.count++;
        if (entry.owner != EntryOwner.partner) stat.hasMe = true;
        if (entry.owner != EntryOwner.me) stat.hasPartner = true;
        day = day.add(const Duration(days: 1));
        guard++;
      }
    }
    return stats;
  }

  Color _hueFor(_DayStat? stat) {
    if (stat == null) return EntryOwner.me.color;
    if (stat.hasMe && stat.hasPartner) return EntryOwner.shared.color;
    if (stat.hasPartner) return EntryOwner.partner.color;
    return EntryOwner.me.color;
  }

  @override
  Widget build(BuildContext context) {
    final stats = _statsByDay();
    final maxCount = stats.values.isEmpty
        ? 0
        : stats.values.map((s) => s.count).reduce((a, b) => a > b ? a : b);

    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7;
    final today = dateOnly(DateTime.now());

    final selected = widget.selectedDay == null ? null : dateOnly(widget.selectedDay!);
    final grid = Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.compact ? 10 : 16),
      child: GridView.builder(
        physics: widget.compact
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        shrinkWrap: widget.compact,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisExtent: widget.compact ? 32 : null,
        ),
        itemCount: leadingBlanks + daysInMonth,
        itemBuilder: (context, index) {
          if (index < leadingBlanks) return const SizedBox.shrink();

          final day = index - leadingBlanks + 1;
          final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
          final stat = stats[date];
          return DayCell(
            day: day,
            count: stat?.count ?? 0,
            maxCount: maxCount,
            hue: _hueFor(stat),
            isToday: date == today,
            isSelected: selected == date,
            onTap: () => widget.onDaySelected(date),
          );
        },
      ),
    );

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: widget.compact ? 0 : 4),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 10 : 16),
          child: Row(
            children: _weekdayLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 4),
        if (widget.compact) grid else Expanded(child: grid),
      ],
    );
  }
}
