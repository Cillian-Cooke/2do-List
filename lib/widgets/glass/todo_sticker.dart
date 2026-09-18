import 'package:flutter/material.dart';

import '../../design.dart';
import '../../models/timeline_entry.dart';
import '../../utils/date_format.dart';
import '../entry_form_sheet.dart';
import '../timeline/dismissible_card.dart';

/// A paper to-do slapped onto a glass sheet. Tilt is stable per title so
/// the pile doesn't reshuffle on rebuilds.
class TodoSticker extends StatelessWidget {
  const TodoSticker({
    super.key,
    required this.entry,
    required this.onToggle,
    required this.onDelete,
    required this.onEdited,
  });

  final TimelineEntry entry;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdited;

  bool get _done => entry is Completable && (entry as Completable).done;

  double get _tilt {
    final hashed = entry.title.hashCode;
    final steps = (hashed % 11) - 5;
    return steps * AppDesign.stickerTilt / 5;
  }

  @override
  Widget build(BuildContext context) {
    final tape = entry.owner.color;
    return Transform.rotate(
      angle: _tilt,
      child: DismissibleCard(
        entryKey: ValueKey(entry),
        onDismissed: onDelete,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Material(
              color: AppDesign.surface,
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.32),
              borderRadius: BorderRadius.circular(AppDesign.radiusSticker),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDesign.radiusSticker),
                onTap: () => showEntryFormSheet(
                  context,
                  initial: entry,
                  onSaved: onEdited,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 20, 8, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                                decoration: _done ? TextDecoration.lineThrough : null,
                                color: Colors.black.withValues(alpha: _done ? 0.4 : 0.82),
                              ),
                            ),
                            if (entry.startDate != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                entry.endDate == null
                                    ? formatTime(entry.startDate!)
                                    : '${formatTime(entry.startDate!)} – ${formatTime(entry.endDate!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: tape.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (entry is Completable)
                        Checkbox(
                          value: _done,
                          onChanged: (_) => onToggle(),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide(color: tape, width: 2),
                          activeColor: tape,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -7,
              child: Transform.rotate(
                angle: -0.08,
                child: Container(
                  width: 58,
                  height: 16,
                  decoration: BoxDecoration(
                    color: tape.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
