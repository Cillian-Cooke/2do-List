import 'package:flutter/material.dart';

import '../utils/date_format.dart';

/// Shown atop the list view when it's filtered down to a single day
/// (after tapping a day in the calendar). Lets the user clear the filter.
class DayFilterBanner extends StatelessWidget {
  const DayFilterBanner({super.key, required this.date, required this.onClear});

  final DateTime date;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.filter_alt_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Showing ${formatDate(date)}')),
            TextButton(onPressed: onClear, child: const Text('Show all')),
          ],
        ),
      ),
    );
  }
}
