import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A [CustomPainter] that renders an animated circular arc progress ring.
///
/// Used internally by [NeomorphicSpendCard] to visualise the budget
/// utilisation. The arc sweeps clockwise from the top (−π/2) and
/// places a filled dot at the leading tip for a polished finish.
///
/// You can use this painter independently in your own widgets:
/// ```dart
/// CustomPaint(
///   painter: ArcPainter(
///     progress: 0.72,
///     arcColor: Colors.teal,
///     trackColor: Colors.grey.shade200,
///     strokeWidth: 10,
///   ),
///   size: const Size(140, 140),
/// )
/// ```
class ArcPainter extends CustomPainter {
  /// 0.0 → 1.0 representing sweep fraction of a full circle.
  final double progress;

  /// Color of the animated arc stroke.
  final Color arcColor;

  /// Color of the background track circle.
  final Color trackColor;

  /// Thickness of both the track and the arc stroke.
  final double strokeWidth;

  const ArcPainter({
    required this.progress,
    required this.arcColor,
    required this.trackColor,
    this.strokeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - strokeWidth;

    // ── Track ────────────────────────────────────────────────────────────────
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // ── Arc ──────────────────────────────────────────────────────────────────
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = arcColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    // ── Tip dot ──────────────────────────────────────────────────────────────
    if (progress > 0.02) {
      final tipAngle = startAngle + sweepAngle;
      final tipX = center.dx + radius * math.cos(tipAngle);
      final tipY = center.dy + radius * math.sin(tipAngle);

      canvas.drawCircle(
        Offset(tipX, tipY),
        strokeWidth / 2,
        Paint()..color = arcColor,
      );
    }
  }

  @override
  bool shouldRepaint(ArcPainter old) =>
      old.progress != progress ||
      old.arcColor != arcColor ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
