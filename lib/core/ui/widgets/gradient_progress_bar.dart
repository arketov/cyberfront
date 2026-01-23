import 'package:flutter/material.dart';

import 'package:cyberdriver/core/theme/app_theme.dart';

class GradientProgressBar extends StatelessWidget {
  const GradientProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.width,
    this.radius = 999,
    this.backgroundColor,
    this.gradientStart,
    this.gradientEnd,
  }) : assert(height > 0);

  final double value;
  final double height;
  final double? width;
  final double radius;
  final Color? backgroundColor;
  final Color? gradientStart;
  final Color? gradientEnd;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>();
    final start = gradientStart ?? palette?.blue ?? const Color(0xFF083BFF);
    final end = gradientEnd ?? palette?.pink ?? const Color(0xFFFF2BD6);
    final bg = backgroundColor ?? palette?.line ?? Colors.white24;
    final progress = (value.clamp(0, 100) as num).toDouble() / 100.0;

    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: _GradientProgressPainter(
          progress: progress.clamp(0.0, 1.0),
          backgroundColor: bg,
          start: start,
          end: end,
          radius: radius,
        ),
      ),
    );
  }
}

class _GradientProgressPainter extends CustomPainter {
  _GradientProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.start,
    required this.end,
    required this.radius,
  });

  final double progress;
  final Color backgroundColor;
  final Color start;
  final Color end;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveRadius = radius.clamp(0.0, size.height / 2);
    final r = Radius.circular(effectiveRadius);

    final bgPaint = Paint()..color = backgroundColor;
    final bgRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: r,
      bottomLeft: r,
      topRight: r,
      bottomRight: r,
    );
    canvas.drawRRect(bgRRect, bgPaint);

    if (progress <= 0 || size.width <= 0) {
      return;
    }

    final fillWidth = size.width * progress.clamp(0.0, 1.0);
    final fillRect = Rect.fromLTWH(0, 0, fillWidth, size.height);
    final fillRRect = RRect.fromRectAndCorners(
      fillRect,
      topLeft: r,
      bottomLeft: r,
      topRight: progress >= 1 ? r : Radius.zero,
      bottomRight: progress >= 1 ? r : Radius.zero,
    );

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[start, end],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(fillRRect, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant _GradientProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.radius != radius;
  }
}
