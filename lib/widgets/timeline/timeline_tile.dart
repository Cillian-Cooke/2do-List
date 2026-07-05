import 'package:flutter/material.dart';

/// Shared layout for one row of the timeline: a dot on a connecting line,
/// with arbitrary content next to it. Task and event tiles both wrap their
/// content in this so the timeline reads as one continuous line.
class TimelineTile extends StatelessWidget {
  const TimelineTile({
    super.key,
    required this.icon,
    required this.color,
    required this.isFirst,
    required this.isLast,
    required this.child,
  });

  final IconData icon;
  final Color color;
  final bool isFirst;
  final bool isLast;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 12,
                  color: isFirst ? Colors.transparent : lineColor,
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Icon(icon, size: 16, color: Colors.white),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : lineColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
