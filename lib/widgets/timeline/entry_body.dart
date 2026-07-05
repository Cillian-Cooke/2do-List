import 'package:flutter/material.dart';

import '../../models/timeline_entry.dart';
import 'importance_badge.dart';

/// The part of a timeline card shared by all entry types: date range,
/// importance, and people. The description is deliberately left out —
/// it only shows in the edit popup (see entry_form_sheet.dart). Goals
/// never have a date, so their row skips straight to the importance
/// badge instead of showing a permanent "No date".
class EntryBody extends StatelessWidget {
  const EntryBody({super.key, required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final subtleStyle = Theme.of(context).textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (entry is GoalEntry)
              const Spacer()
            else ...[
              Icon(
                entry.startDate == null ? Icons.event_busy : Icons.schedule,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(entry.formattedRange, style: subtleStyle)),
            ],
            ImportanceBadge(importance: entry.importance),
          ],
        ),
        if (entry.people.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: entry.people
                .map(
                  (person) => Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.person, size: 14),
                    label: Text(person, style: const TextStyle(fontSize: 12)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
