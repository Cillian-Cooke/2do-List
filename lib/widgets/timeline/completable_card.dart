import 'package:flutter/material.dart';

import '../../design.dart';
import '../../models/timeline_entry.dart';
import '../entry_form_sheet.dart';
import 'dismissible_card.dart';
import 'entry_body.dart';

/// Shared card content for entries with a checkbox (tasks and goals): a
/// tappable title area that opens the edit popup (also where the
/// description shows), plus a checkbox kept as a separate tap target so
/// it stays dedicated to toggling done.
///
/// Set [dense]/[showBody] false to get the compact, title-only styling
/// goals use — see goal_tile.dart.
class CompletableCard extends StatelessWidget {
  const CompletableCard({
    super.key,
    required this.entry,
    required this.onToggle,
    required this.onDelete,
    required this.onEdited,
    this.showBody = true,
    this.dense = false,
    this.leadingIcon,
    this.leadingColor,
  });

  final TimelineEntry entry;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdited;
  final bool showBody;
  final bool dense;
  final IconData? leadingIcon;
  final Color? leadingColor;

  bool get _done => (entry as Completable).done;

  @override
  Widget build(BuildContext context) {
    return DismissibleCard(
      entryKey: ValueKey(entry),
      onDismissed: onDelete,
      child: Card(
        margin: EdgeInsets.zero,
        color: entry.owner.color.withValues(alpha: AppDesign.cardTint),
        child: Padding(
          padding: EdgeInsets.all(dense ? 2 : 4),
          child: Row(
            crossAxisAlignment: showBody ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDesign.radiusSmall),
                  onTap: () => showEntryFormSheet(
                    context,
                    initial: entry,
                    onSaved: onEdited,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: dense ? 4 : 8,
                    ),
                    child: showBody
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _title(context),
                              const SizedBox(height: 4),
                              EntryBody(entry: entry),
                            ],
                          )
                        : _title(context),
                  ),
                ),
              ),
              Checkbox(
                value: _done,
                onChanged: (_) => onToggle(),
                visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    final text = Text(
      entry.title,
      style: TextStyle(
        fontSize: dense ? AppDesign.bodySize : AppDesign.entryTitleSize,
        fontWeight: dense ? FontWeight.w500 : AppDesign.entryTitleWeight,
        decoration: _done ? TextDecoration.lineThrough : null,
      ),
    );

    if (leadingIcon == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(leadingIcon, size: 15, color: leadingColor),
        const SizedBox(width: 6),
        Flexible(child: text),
      ],
    );
  }
}
