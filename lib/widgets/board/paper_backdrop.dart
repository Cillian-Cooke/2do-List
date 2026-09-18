import 'package:flutter/material.dart';

import '../../design.dart';
import 'day_clock.dart';

/// Ruled paper for the day: one line per hour from 6am to 11pm.
class PaperBackdrop extends StatelessWidget {
  const PaperBackdrop({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _PaperPainter(),
      child: child,
    );
  }
}

class _PaperPainter extends CustomPainter {
  const _PaperPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = AppDesign.background;
    canvas.drawRect(Offset.zero & size, fill);

    final line = Paint()
      ..color = AppDesign.paperLine.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    final hourLine = Paint()
      ..color = AppDesign.paperLine.withValues(alpha: 0.9)
      ..strokeWidth = 1.15;

    final hourLabel = TextPainter(textDirection: TextDirection.ltr);
    final start = DayClock.startHour.toInt();
    final end = DayClock.endHour.toInt();
    for (var hour = start; hour <= end; hour++) {
      final y = DayClock.yFor(
        DateTime(2000, 1, 1, hour),
        size.height,
      );
      canvas.drawLine(Offset(36, y), Offset(size.width, y), hour % 3 == 0 ? hourLine : line);
      if (hour % 2 == 0) {
        hourLabel.text = TextSpan(
          text: hour.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 10,
            height: 1,
            color: Colors.black.withValues(alpha: 0.32),
          ),
        );
        hourLabel.layout();
        hourLabel.paint(canvas, Offset(8, y - 5));
      }
    }

    final margin = Paint()
      ..color = AppDesign.meColor.withValues(alpha: 0.18)
      ..strokeWidth = 1.4;
    canvas.drawLine(const Offset(14, 0), Offset(14, size.height), margin);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
