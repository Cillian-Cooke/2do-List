import 'package:flutter/material.dart';

import '../../design.dart';
import '../../models/timeline_entry.dart';
import 'completable_card.dart';

/// Compact row for a [GoalEntry]: no date, no timeline dot/line — just a
/// small flag icon, title, and checkbox. Deliberately lighter-weight
/// than task/event tiles since goals are pinned above them, not part of
/// the chronological line. Pinning itself happens in [TimelineList].
class GoalTile extends StatelessWidget {
  const GoalTile({
    super.key,
    required this.entry,
    required this.onToggle,
    required this.onDelete,
    required this.onEdited,
  });

  final GoalEntry entry;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdited;

  @override
  Widget build(BuildContext context) {
    final color = entry.done
        ? entry.owner.color.withValues(alpha: AppDesign.doneFade)
        : entry.owner.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: CompletableCard(
        entry: entry,
        onToggle: onToggle,
        onDelete: onDelete,
        onEdited: onEdited,
        showBody: false,
        dense: true,
        leadingIcon: entry.done ? Icons.check : Icons.flag_outlined,
        leadingColor: color,
      ),
    );
  }
}
