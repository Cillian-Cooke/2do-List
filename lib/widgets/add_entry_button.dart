import 'package:flutter/material.dart';

import '../models/timeline_entry.dart';
import 'entry_form_sheet.dart';

/// Button that opens the add-entry popup (see entry_form_sheet.dart). Sized
/// by its parent — see bottom_action_bar.dart for where it's placed.
class AddEntryButton extends StatelessWidget {
  const AddEntryButton({super.key, required this.onCreate});

  final void Function(TimelineEntry entry) onCreate;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => showEntryFormSheet(context, onCreate: onCreate),
      icon: const Icon(Icons.add),
      label: const Text('Add to timeline'),
    );
  }
}
