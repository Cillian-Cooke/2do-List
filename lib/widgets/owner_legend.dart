import 'package:flutter/material.dart';

import '../models/timeline_entry.dart';

/// Small "pink = me, blue = partner, purple = shared" key shown under the
/// whose-filter toggle so the color coding is legible on its own.
class OwnerLegend extends StatelessWidget {
  const OwnerLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final owner in EntryOwner.values) ...[
          Icon(Icons.circle, size: 10, color: owner.color),
          const SizedBox(width: 4),
          Text(
            owner == EntryOwner.me ? 'You' : owner.label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (owner != EntryOwner.values.last) const SizedBox(width: 14),
        ],
      ],
    );
  }
}
