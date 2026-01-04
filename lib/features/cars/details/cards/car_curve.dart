// lib/features/cars/details/cards/car_curve.dart
import 'dart:math';

import 'package:cyberdriver/core/theme/app_theme.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/shared/models/car_dto.dart';
import 'package:flutter/material.dart';

class CarCurveCard extends CardBase {
  const CarCurveCard({
    super.key,
    required this.power,
    required this.torque,
  });

  final List<CarCurvePoint> power;
  final List<CarCurvePoint> torque;

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.zero;

  @override
  Widget buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pal = Theme.of(context).extension<AppPalette>();
    const contentPadding = EdgeInsets.fromLTRB(18, 14, 18, 16);

    final hasData = power.isNotEmpty || torque.isNotEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 140),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: .99),
                      Colors.black.withValues(alpha: .50),
                      Colors.black.withValues(alpha: .20),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('[ЭТО ГРАФИК]'),
                  const SizedBox(height: 10),
                  _CurveLegend(
                    powerColor: pal?.pink ?? cs.primary,
                    torqueColor: pal?.blue ?? cs.secondary,
                  ),
                  const SizedBox(height: 12),
                  if (!hasData)
                    Text(
                      'Нет данных',
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(.75),
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: _CurveChart(
                        power: power,
                        torque: torque,
                        powerColor: pal?.pink ?? cs.primary,
                        torqueColor: pal?.blue ?? cs.secondary,
                        gridColor: pal?.line ?? cs.onSurface.withOpacity(0.12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurveLegend extends StatelessWidget {
  const _CurveLegend({
    required this.powerColor,
    required this.torqueColor,
  });

  final Color powerColor;
  final Color torqueColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textStyle = TextStyle(
      color: cs.onSurface.withOpacity(0.85),
      fontWeight: FontWeight.w700,
    );

    return Row(
      children: [
        _LegendDot(color: powerColor),
        const SizedBox(width: 6),
        Text('POWER', style: textStyle),
        const SizedBox(width: 14),
        _LegendDot(color: torqueColor),
        const SizedBox(width: 6),
        Text('TORQUE', style: textStyle),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _CurveChart extends StatelessWidget {
  const _CurveChart({
    required this.power,
    required this.torque,
    required this.powerColor,
    required this.torqueColor,
    required this.gridColor,
  });

  final List<CarCurvePoint> power;
  final List<CarCurvePoint> torque;
  final Color powerColor;
  final Color torqueColor;
  final Color gridColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return SizedBox(
          width: c.maxWidth,
          height: c.maxHeight,
          child: CustomPaint(
            painter: _CurveChartPainter(
              power: power,
              torque: torque,
              powerColor: powerColor,
              torqueColor: torqueColor,
              gridColor: gridColor,
              labelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
            ),
          ),
        );
      },
    );
  }
}

class _CurveChartPainter extends CustomPainter {
  _CurveChartPainter({
    required this.power,
    required this.torque,
    required this.powerColor,
    required this.torqueColor,
    required this.gridColor,
    required this.labelColor,
  });

  final List<CarCurvePoint> power;
  final List<CarCurvePoint> torque;
  final Color powerColor;
  final Color torqueColor;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (power.isEmpty && torque.isEmpty) return;

    final all = <CarCurvePoint>[...power, ...torque];
    final minX = all.map((e) => e.rpm).reduce(min).toDouble();
    var maxX = all.map((e) => e.rpm).reduce(max).toDouble();
    var maxY = all.map((e) => e.value).reduce(max);

    if (maxX - minX < 1) {
      maxX = minX + 1;
    }
    if (maxY <= 0) {
      maxY = 1;
    }

    const leftPad = 36.0;
    const bottomPad = 22.0;
    const rightPad = 8.0;
    const topPad = 8.0;
    final chart = Rect.fromLTWH(
      leftPad,
      topPad,
      size.width - leftPad - rightPad,
      size.height - topPad - bottomPad,
    );
    final xScale = chart.width / (maxX - minX);
    final yScale = chart.height / maxY;

    _drawGrid(canvas, chart);
    _drawAxisLabels(canvas, chart, minX, maxX, maxY);
    _drawLine(canvas, chart, power, minX, xScale, yScale, powerColor);
    _drawLine(canvas, chart, torque, minX, xScale, yScale, torqueColor);
  }

  void _drawGrid(Canvas canvas, Rect chart) {
    final paint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const divisions = 4;
    for (var i = 1; i < divisions; i++) {
      final dx = chart.left + chart.width * i / divisions;
      final dy = chart.top + chart.height * i / divisions;
      canvas.drawLine(Offset(dx, chart.top), Offset(dx, chart.bottom), paint);
      canvas.drawLine(Offset(chart.left, dy), Offset(chart.right, dy), paint);
    }
    canvas.drawRect(chart, paint);
  }

  void _drawAxisLabels(Canvas canvas, Rect chart, double minX, double maxX, double maxY) {
    final textStyle = TextStyle(
      color: labelColor,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    const xTicks = 3;
    for (var i = 0; i < xTicks; i++) {
      final t = i / (xTicks - 1);
      final value = minX + (maxX - minX) * t;
      final label = _formatRpm(value);
      final x = chart.left + chart.width * t;
      _drawText(canvas, label, Offset(x, chart.bottom + 4), textStyle, align: TextAlign.center);
    }

    const yTicks = 3;
    for (var i = 0; i < yTicks; i++) {
      final t = i / (yTicks - 1);
      final value = maxY * (1 - t);
      final y = chart.top + chart.height * t;
      final label = _formatValue(value);
      _drawText(canvas, label, Offset(chart.left - 6, y - 6), textStyle, align: TextAlign.right);
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style, {TextAlign align = TextAlign.left}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = align == TextAlign.center ? offset.dx - tp.width / 2 : offset.dx - (align == TextAlign.right ? tp.width : 0);
    tp.paint(canvas, Offset(dx, offset.dy));
  }

  String _formatRpm(double value) => '${value.round()}';

  String _formatValue(double value) => value.round().toString();

  void _drawLine(
    Canvas canvas,
    Rect chart,
    List<CarCurvePoint> points,
    double minX,
    double xScale,
    double yScale,
    Color color,
  ) {
    if (points.length < 2) return;
    final sorted = [...points]..sort((a, b) => a.rpm.compareTo(b.rpm));
    final path = _smoothPath(sorted, chart, minX, xScale, yScale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  Path _smoothPath(
    List<CarCurvePoint> points,
    Rect chart,
    double minX,
    double xScale,
    double yScale,
  ) {
    final p = points
        .map((e) => Offset(
              chart.left + (e.rpm - minX) * xScale,
              chart.bottom - (e.value * yScale),
            ))
        .toList(growable: false);

    final path = Path()..moveTo(p.first.dx, p.first.dy);
    for (var i = 0; i < p.length - 1; i++) {
      final current = p[i];
      final next = p[i + 1];
      final mid = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      if (i == 0) {
        path.lineTo(mid.dx, mid.dy);
      } else {
        path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
      }
    }
    path.lineTo(p.last.dx, p.last.dy);
    return path;
  }

  @override
  bool shouldRepaint(covariant _CurveChartPainter oldDelegate) {
    return oldDelegate.power != power ||
        oldDelegate.torque != torque ||
        oldDelegate.powerColor != powerColor ||
        oldDelegate.torqueColor != torqueColor ||
        oldDelegate.gridColor != gridColor;
  }
}
