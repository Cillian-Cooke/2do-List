import 'package:flutter/material.dart';

import '../models/timeline_entry.dart';
import 'add_entry_button.dart';
import 'view_mode.dart';
import 'whose_filter_button.dart';

/// Pinned to the bottom of the home screen: the whose-filter button, a
/// boolean view toggle, and the add button. The view toggle icon shows
/// the view it switches *to* — a calendar glyph while on the list view, a
/// list glyph while on the calendar view. The whose-filter button cycles
/// Both → Mine → Theirs → Both on each tap.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.mode,
    required this.onToggleMode,
    required this.whoseFilter,
    required this.onWhoseFilterChanged,
    required this.onCreate,
  });

  final ViewMode mode;
  final VoidCallback onToggleMode;
  final WhoseFilter whoseFilter;
  final ValueChanged<WhoseFilter> onWhoseFilterChanged;
  final void Function(TimelineEntry entry) onCreate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SizedBox(
        height: 52,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 52,
              child: WhoseFilterButton(
                value: whoseFilter,
                onChanged: onWhoseFilterChanged,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 52,
              child: IconButton.filledTonal(
                onPressed: onToggleMode,
                icon: Icon(
                  mode == ViewMode.list
                      ? Icons.calendar_month_outlined
                      : Icons.view_agenda_outlined,
                ),
                tooltip: mode == ViewMode.list
                    ? 'Switch to calendar view'
                    : 'Switch to list view',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: AddEntryButton(onCreate: onCreate)),
          ],
        ),
      ),
    );
  }
}
