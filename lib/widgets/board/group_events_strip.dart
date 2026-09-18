import 'package:flutter/material.dart';

import '../../design.dart';
import '../../models/timeline_entry.dart';
import '../../utils/date_format.dart';
import '../entry_form_sheet.dart';

/// Shared plans for the selected day, pinned across the top of the board.
class GroupEventsStrip extends StatelessWidget {
  const GroupEventsStrip({
    super.key,
    required this.events,
    required this.day,
    required this.onAdd,
    required this.onEdited,
  });

  final List<EventEntry> events;
  final DateTime day;
  final VoidCallback onAdd;
  final VoidCallback onEdited;

  @override
  Widget build(BuildContext context) {
    final color = EntryOwner.shared.color;
    return Material(
      color: color.withValues(alpha: 0.10),
      child: SizedBox(
        height: AppDesign.groupStripHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 36,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 4, 0),
                child: Row(
                  children: [
                    Icon(Icons.groups_2_outlined, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      'Group',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Add group event',
                      onPressed: onAdd,
                      icon: Icon(Icons.add, color: color, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No plans together yet',
                          style: TextStyle(color: color.withValues(alpha: 0.7)),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Align(
                          child: _GroupChip(
                            event: event,
                            color: color,
                            onEdited: onEdited,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  const _GroupChip({
    required this.event,
    required this.color,
    required this.onEdited,
  });

  final EventEntry event;
  final Color color;
  final VoidCallback onEdited;

  @override
  Widget build(BuildContext context) {
    final time = event.startDate == null ? '' : formatTime(event.startDate!);
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => showEntryFormSheet(
          context,
          initial: event,
          onSaved: onEdited,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (time.isNotEmpty) ...[
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
