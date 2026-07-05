import 'package:flutter/material.dart';

import '../../design.dart';

/// A card that can be swiped away to delete. Shared by task and event
/// tiles so both get the same delete gesture and background.
class DismissibleCard extends StatelessWidget {
  const DismissibleCard({
    super.key,
    required this.entryKey,
    required this.onDismissed,
    required this.child,
  });

  final Key entryKey;
  final VoidCallback onDismissed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: entryKey,
      onDismissed: (_) => onDismissed(),
      background: Container(
        decoration: BoxDecoration(
          color: AppDesign.danger,
          borderRadius: BorderRadius.circular(AppDesign.radiusCard),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: child,
    );
  }
}
