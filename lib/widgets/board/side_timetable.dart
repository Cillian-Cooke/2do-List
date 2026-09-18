import 'package:flutter/material.dart';

import '../../design.dart';
import '../../models/timeline_entry.dart';
import '../../utils/date_format.dart';
import '../entry_form_sheet.dart';
import 'day_clock.dart';

/// A slim day-schedule rail: hour spine + event blocks for one person.
class SideTimetable extends StatelessWidget {
  const SideTimetable({
    super.key,
    required this.owner,
    required this.events,
    required this.day,
    this.onAdd,
    this.onEdited,
  });

  final EntryOwner owner;
  final List<EventEntry> events;
  final DateTime day;
  final VoidCallback? onAdd;
  final VoidCallback? onEdited;

  @override
  Widget build(BuildContext context) {
    final color = owner.color;
    return ColoredBox(
      color: color.withValues(alpha: 0.12),
      child: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _TimetableTrack(
                  events: events,
                  day: day,
                  color: color,
                  height: constraints.maxHeight,
                  onEdited: onEdited,
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ColoredBox(
              color: color.withValues(alpha: 0.16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        owner.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: color,
                        ),
                      ),
                    ),
                    if (onAdd != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                        tooltip: 'Add event',
                        onPressed: onAdd,
                        icon: Icon(Icons.add, size: 16, color: color),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimetableTrack extends StatelessWidget {
  const _TimetableTrack({
    required this.events,
    required this.day,
    required this.color,
    required this.height,
    this.onEdited,
  });

  final List<EventEntry> events;
  final DateTime day;
  final Color color;
  final double height;
  final VoidCallback? onEdited;

  double _yFor(DateTime time) => DayClock.yFor(time, height);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final showNow = isSameDay(now, day) &&
        now.hour + now.minute / 60 >= DayClock.startHour &&
        now.hour + now.minute / 60 < DayClock.endHour;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        for (var hour = DayClock.startHour.toInt(); hour <= DayClock.endHour.toInt(); hour += 2)
          Positioned(
            top: _yFor(DateTime(day.year, day.month, day.day, hour)),
            left: 6,
            right: 4,
            child: Text(
              hour.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 9,
                height: 1,
                color: Colors.black.withValues(alpha: 0.38),
              ),
            ),
          ),
        for (var hour = DayClock.startHour.toInt(); hour < DayClock.endHour.toInt(); hour++)
          Positioned(
            top: _yFor(DateTime(day.year, day.month, day.day, hour)),
            left: 0,
            right: 0,
            child: Container(height: 1, color: AppDesign.paperLine.withValues(alpha: 0.65)),
          ),
        for (final event in events)
          if (event.startDate != null)
            Positioned(
              top: _yFor(event.startDate!),
              left: 4,
              right: 4,
              height: () {
                final start = event.startDate!;
                final end = event.endDate ?? start.add(const Duration(hours: 1));
                final raw = _yFor(end) - _yFor(start);
                return raw.clamp(28.0, height);
              }(),
              child: _EventBlock(event: event, color: color, onEdited: onEdited),
            ),
        if (showNow)
          Positioned(
            top: _yFor(now) - 1,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              color: AppDesign.importanceHigh.withValues(alpha: 0.85),
            ),
          ),
        if (events.isEmpty)
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Free',
                style: TextStyle(
                  color: color.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EventBlock extends StatelessWidget {
  const _EventBlock({
    required this.event,
    required this.color,
    this.onEdited,
  });

  final EventEntry event;
  final Color color;
  final VoidCallback? onEdited;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(8),
      elevation: 1.5,
      shadowColor: color.withValues(alpha: 0.45),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onEdited == null
            ? null
            : () => showEntryFormSheet(
                context,
                initial: event,
                onSaved: onEdited,
              ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
          child: Text(
            event.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              height: 1.15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
