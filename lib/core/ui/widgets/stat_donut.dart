import 'package:flutter/material.dart';

import 'package:cyberdriver/core/theme/app_theme.dart';

class StatDonut extends StatelessWidget {
  const StatDonut({
    super.key,
    required this.label,
    required this.value,
    this.tooltipText,
    this.maxValue = 255,
    this.minValue = 0,
  });

  final String label;
  final int value;
  final String? tooltipText;
  final int maxValue;
  final int minValue;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>();
    final accent = palette?.pink ?? Colors.white;
    final muted = palette?.line ?? Colors.white.withValues(alpha: 0.2);
    final clamped = value.clamp(minValue, maxValue);
    final percent = ((clamped / maxValue) * 100).round();

    final tooltipMessage = (tooltipText ?? label).trim();

    return Tooltip(
      message: tooltipMessage.isEmpty ? label : tooltipMessage,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 2),
      preferBelow: false,
      verticalOffset: 12,
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF050505),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
      textStyle: const TextStyle(
        color: Color(0xFF9A9A9A),
        fontSize: 13,
        height: 1.2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(72, 36),
                  painter: _HalfDonutPainter(
                    progress: percent / 100.0,
                    color: accent,
                    backgroundColor: muted,
                    strokeWidth: 6,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  child: Text(
                    '$percent',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HalfDonutPainter extends CustomPainter {
  _HalfDonutPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 8,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = strokeWidth;
    final rect = Rect.fromLTWH(0, 0, size.width, size.width);
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = backgroundColor
      ..strokeCap = StrokeCap.round;
    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color
      ..strokeCap = StrokeCap.round;

    const startAngle = 3.141592653589793;
    const sweepAngle = 3.141592653589793;
    canvas.drawArc(rect, startAngle, sweepAngle, false, bgPaint);
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle * progress.clamp(0.0, 1.0),
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HalfDonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
