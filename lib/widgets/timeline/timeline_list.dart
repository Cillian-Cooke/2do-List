import 'package:flutter/material.dart';

import '../../models/timeline_entry.dart';
import 'event_tile.dart';
import 'goal_tile.dart';
import 'task_tile.dart';

/// Renders every [TimelineEntry] as a connected vertical timeline, picking
/// the right tile widget per entry type. Goals are pinned above
/// everything else under their own header, since they never have a date.
/// Add a new entry type by handling it here and creating a matching tile
/// in this folder.
class TimelineList extends StatelessWidget {
  const TimelineList({
    super.key,
    required this.entries,
    required this.onToggleDone,
    required this.onDelete,
    required this.onEdited,
    this.emptyMessage = 'Nothing here yet. Add a task or event below!',
  });

  final List<TimelineEntry> entries;
  final void Function(TimelineEntry entry) onToggleDone;
  final void Function(TimelineEntry entry) onDelete;
  final VoidCallback onEdited;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    final goals = entries.whereType<GoalEntry>().toList();
    final rest = entries.where((entry) => entry is! GoalEntry).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      children: [
        if (goals.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Goals',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          for (final goal in goals)
            GoalTile(
              entry: goal,
              onToggle: () => onToggleDone(goal),
              onDelete: () => onDelete(goal),
              onEdited: onEdited,
            ),
          const SizedBox(height: 12),
        ],
        for (var i = 0; i < rest.length; i++)
          if (rest[i] case final TaskEntry entry)
            TaskTile(
              entry: entry,
              isFirst: i == 0,
              isLast: i == rest.length - 1,
              onToggle: () => onToggleDone(entry),
              onDelete: () => onDelete(entry),
              onEdited: onEdited,
            )
          else
            EventTile(
              entry: rest[i] as EventEntry,
              isFirst: i == 0,
              isLast: i == rest.length - 1,
              onDelete: () => onDelete(rest[i]),
              onEdited: onEdited,
            ),
      ],
    );
  }
}
