import 'package:flutter/material.dart';

import '../../design.dart';
import '../../models/timeline_entry.dart';
import '../entry_form_sheet.dart';
import 'dismissible_card.dart';
import 'entry_body.dart';
import 'timeline_tile.dart';

/// Timeline row for an [EventEntry]: no checkbox, just a marker in time.
/// Tap it to open the edit popup (also where the description shows).
class EventTile extends StatelessWidget {
  const EventTile({
    super.key,
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.onDelete,
    required this.onEdited,
  });

  final EventEntry entry;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onDelete;
  final VoidCallback onEdited;

  @override
  Widget build(BuildContext context) {
    final color = entry.owner.color;

    return TimelineTile(
      icon: Icons.event,
      color: color,
      isFirst: isFirst,
      isLast: isLast,
      child: DismissibleCard(
        entryKey: ValueKey(entry),
        onDismissed: onDelete,
        child: Card(
          margin: EdgeInsets.zero,
          color: color.withValues(alpha: AppDesign.cardTint),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDesign.radiusCard),
            onTap: () => showEntryFormSheet(
              context,
              initial: entry,
              onSaved: onEdited,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: AppDesign.entryTitleSize,
                      fontWeight: AppDesign.entryTitleWeight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  EntryBody(entry: entry),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
