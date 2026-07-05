import 'package:flutter/material.dart';

import '../models/timeline_entry.dart';

/// Whose entries the home screen currently shows.
enum WhoseFilter { both, mine, theirs }

extension WhoseFilterMatch on WhoseFilter {
  /// Whether an entry owned by [owner] should show under this filter.
  /// Shared entries always show for both "mine" and "theirs" since both
  /// people are on them.
  bool matches(EntryOwner owner) => switch (this) {
    WhoseFilter.both => true,
    WhoseFilter.mine => owner != EntryOwner.partner,
    WhoseFilter.theirs => owner != EntryOwner.me,
  };

  WhoseFilter get next => switch (this) {
    WhoseFilter.both => WhoseFilter.mine,
    WhoseFilter.mine => WhoseFilter.theirs,
    WhoseFilter.theirs => WhoseFilter.both,
  };
}

/// Single button pinned to the bottom bar that cycles Both → Mine →
/// Theirs → Both on each tap, tinting pink/blue to match the owner
/// coloring used across the list and calendar.
class WhoseFilterButton extends StatelessWidget {
  const WhoseFilterButton({super.key, required this.value, required this.onChanged});

  final WhoseFilter value;
  final ValueChanged<WhoseFilter> onChanged;

  IconData get _icon => switch (value) {
    WhoseFilter.both => Icons.people_alt_outlined,
    WhoseFilter.mine => Icons.person,
    WhoseFilter.theirs => Icons.person,
  };

  Color? get _color => switch (value) {
    WhoseFilter.both => null,
    WhoseFilter.mine => EntryOwner.me.color,
    WhoseFilter.theirs => EntryOwner.partner.color,
  };

  String get _tooltip => switch (value) {
    WhoseFilter.both => 'Showing both — tap for just you',
    WhoseFilter.mine => 'Showing just you — tap for just your partner',
    WhoseFilter.theirs => 'Showing just your partner — tap for both',
  };

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: () => onChanged(value.next),
      tooltip: _tooltip,
      icon: Icon(_icon, color: _color),
    );
  }
}
