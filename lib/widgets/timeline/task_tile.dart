import 'package:flutter/material.dart';

import '../../design.dart';
import '../../models/timeline_entry.dart';
import 'completable_card.dart';
import 'timeline_tile.dart';

/// Timeline row for a [TaskEntry]: checkbox, strikethrough when done.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.onToggle,
    required this.onDelete,
    required this.onEdited,
  });

  final TaskEntry entry;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdited;

  @override
  Widget build(BuildContext context) {
    final color = entry.done
        ? entry.owner.color.withValues(alpha: AppDesign.doneFade)
        : entry.owner.color;

    return TimelineTile(
      icon: entry.done ? Icons.check : Icons.radio_button_unchecked,
      color: color,
      isFirst: isFirst,
      isLast: isLast,
      child: CompletableCard(
        entry: entry,
        onToggle: onToggle,
        onDelete: onDelete,
        onEdited: onEdited,
      ),
    );
  }
}
