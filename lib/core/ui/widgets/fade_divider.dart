// lib/core/ui/fade_divider.dart
import 'package:flutter/material.dart';

class FadeDivider extends StatelessWidget {
  const FadeDivider({
    super.key,
    this.height = 1,
    this.color = const Color(0xFF515151),
    this.edgeStop = 0.3,
  }) : assert(height > 0),
        assert(edgeStop > 0 && edgeStop < 0.5);

  final double height;
  final Color color;

  /// Где заканчивается "прозрачный край" и начинается сплошная линия.
  /// Симметрично с двух сторон: [0, edgeStop, 1-edgeStop, 1].
  final double edgeStop;

  @override
  Widget build(BuildContext context) {
    final s = edgeStop.clamp(0.0001, 0.4999);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: <double>[0, s, 1 - s, 1],
            colors: <Color>[
              Colors.transparent,
              color,
              color,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
