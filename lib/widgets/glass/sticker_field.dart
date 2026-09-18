import 'package:flutter/material.dart';

import '../../design.dart';
import '../../models/timeline_entry.dart';
import '../board/day_clock.dart';
import 'todo_sticker.dart';

/// Stickers sit on the paper at their clock time so 6am is at the top
/// and 11pm at the bottom. The same slot is used for every owner, which
/// is why stacked glasses cover each other when two people have something
/// at the same time.
class StickerField extends StatelessWidget {
  const StickerField({
    super.key,
    required this.entries,
    required this.progress,
    required this.emptyLabel,
    required this.onToggle,
    required this.onDelete,
    required this.onEdited,
    required this.viewPadding,
  });

  final List<TimelineEntry> entries;
  final double progress;
  final String emptyLabel;
  final void Function(TimelineEntry entry) onToggle;
  final void Function(TimelineEntry entry) onDelete;
  final VoidCallback onEdited;
  final EdgeInsets viewPadding;

  static const _stickerSlot = 88.0;

  EdgeInsets _paperInsets() {
    final inset = AppDesign.glassInset;
    return EdgeInsets.fromLTRB(
      (28.0 - inset).clamp(8.0, 40.0),
      (viewPadding.top - inset).clamp(0.0, 80.0),
      (28.0 - inset).clamp(8.0, 40.0),
      (viewPadding.bottom + AppDesign.calendarHeight - inset).clamp(0.0, 800.0),
    );
  }

  double _yFor(TimelineEntry entry, double height) {
    final fraction = DayClock.fractionFor(entry.startDate);
    if (fraction == null) {
      return (height - _stickerSlot).clamp(0.0, height);
    }
    final y = fraction * height;
    return y.clamp(0.0, (height - _stickerSlot).clamp(0.0, height));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _paperInsets(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (entries.isEmpty) {
            return Center(
              child: Opacity(
                opacity: progress.clamp(0.0, 1.0),
                child: Text(
                  emptyLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    shadows: const [Shadow(blurRadius: 8, color: Colors.black26)],
                  ),
                ),
              ),
            );
          }

          final height = constraints.maxHeight;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (var index = 0; index < entries.length; index++)
                _placedSticker(entries[index], index, height),
            ],
          );
        },
      ),
    );
  }

  Widget _placedSticker(TimelineEntry entry, int index, double height) {
    final start = 0.10 + index * 0.05;
    final t = ((progress - start) / 0.38).clamp(0.0, 1.0);
    final popped = Curves.easeOutBack.transform(t);
    final top = _yFor(entry, height);

    return Positioned(
      top: top,
      left: 4,
      right: 4,
      child: Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - popped)),
          child: Transform.scale(
            alignment: Alignment.topCenter,
            scale: 0.88 + 0.12 * popped.clamp(0.0, 1.15),
            child: TodoSticker(
              entry: entry,
              onToggle: () => onToggle(entry),
              onDelete: () => onDelete(entry),
              onEdited: onEdited,
            ),
          ),
        ),
      ),
    );
  }
}

/// Title painted onto the glass so you always know whose pile this is.
class GlassHeader extends StatelessWidget {
  const GlassHeader({
    super.key,
    required this.title,
    required this.color,
    required this.progress,
  });

  final String title;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: progress.clamp(0.0, 1.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppDesign.edgeHit + 16, 18, 24, 0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: Colors.white,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.8), blurRadius: 12),
                const Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
