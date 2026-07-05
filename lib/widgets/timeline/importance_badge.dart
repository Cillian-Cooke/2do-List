import 'package:flutter/material.dart';

import '../../design.dart';
import '../../models/timeline_entry.dart';

/// Small colored pill showing an entry's importance level.
class ImportanceBadge extends StatelessWidget {
  const ImportanceBadge({super.key, required this.importance});

  final Importance importance;

  Color get _color => switch (importance) {
    Importance.low => AppDesign.importanceLow,
    Importance.medium => AppDesign.importanceMedium,
    Importance.high => AppDesign.importanceHigh,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: AppDesign.badgeFill),
        borderRadius: BorderRadius.circular(AppDesign.radiusCard),
        border: Border.all(color: _color.withValues(alpha: AppDesign.badgeBorder)),
      ),
      child: Text(
        importance.label,
        style: TextStyle(
          color: _color,
          fontSize: AppDesign.captionSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
