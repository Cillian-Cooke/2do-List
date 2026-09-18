import 'dart:ui';

import 'package:flutter/material.dart';

import '../../design.dart';

/// Continuous liquid glass — the whole sheet is frosted, and the rim
/// thickens with a blurred highlight instead of a clipped blur strip.
class GlassPane extends StatelessWidget {
  const GlassPane({
    super.key,
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  static ImageFilter get _liquidFilter => ImageFilter.compose(
        outer: ImageFilter.blur(
          sigmaX: AppDesign.glassBlur,
          sigmaY: AppDesign.glassBlur,
          tileMode: TileMode.mirror,
        ),
        inner: const ColorFilter.matrix(_saturate),
      );

  /// Rec.709 saturate ~1.35, the same trick iOS uses behind glass.
  static const _saturate = <double>[
    1.276, -0.250, -0.025, 0, 0,
    -0.074, 1.065, -0.025, 0, 0,
    -0.074, -0.250, 1.325, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDesign.radiusGlass);
    final tint = Color.lerp(
      Colors.white.withValues(alpha: 0.22),
      color.withValues(alpha: AppDesign.glassTint),
      0.72,
    )!;

    return Padding(
      padding: const EdgeInsets.all(AppDesign.glassInset),
      child: CustomPaint(
        painter: _GlassBloomPainter(color: color, radius: AppDesign.radiusGlass),
        child: ClipRRect(
          borderRadius: radius,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: BackdropFilter(
            filter: _liquidFilter,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: AppDesign.glassHighlight),
                        tint,
                        Color.lerp(tint, color, 0.35)!
                            .withValues(alpha: 0.18),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    painter: _LiquidRimPainter(radius: AppDesign.radiusGlass),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft colored halo outside the clip so the frost doesn't meet air as a knife edge.
class _GlassBloomPainter extends CustomPainter {
  _GlassBloomPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    canvas.drawRRect(
      rrect.shift(const Offset(0, 10)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
    );
  }

  @override
  bool shouldRepaint(covariant _GlassBloomPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Specular rim + inner refraction — lighting, not a second clipped blur.
class _LiquidRimPainter extends CustomPainter {
  _LiquidRimPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    canvas.drawRRect(
      rrect.deflate(10),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..color = const Color(0x55FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    canvas.drawRRect(
      rrect.deflate(1.2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.92),
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.38),
          ],
          stops: const [0.0, 0.28, 0.7, 1.0],
        ).createShader(Offset.zero & size),
    );

    final sheen = Path()
      ..addRRect(rrect.deflate(1))
      ..addRect(Rect.fromLTWH(0, size.height * 0.22, size.width, size.height));
    sheen.fillType = PathFillType.evenOdd;
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawPath(
      sheen,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.38),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.28)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LiquidRimPainter oldDelegate) =>
      oldDelegate.radius != radius;
}

/// Grab tab on the origin edge of the top-most glass sheet.
class SheetHandle extends StatelessWidget {
  const SheetHandle({
    super.key,
    required this.color,
    required this.axis,
  });

  final Color color;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final isVertical = axis == Axis.vertical;
    return Center(
      child: Container(
        width: isVertical ? 5 : 48,
        height: isVertical ? 48 : 5,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(99),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}
