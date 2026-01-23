import 'dart:io';

import 'package:flutter/material.dart';

class RadialFadeImage extends StatelessWidget {
  const RadialFadeImage({
    super.key,
    required this.file,
    this.radius = 0.5,
    this.stops = const [0.0, 0.6, 1.0],
    this.colors = const [Colors.white, Colors.white, Colors.transparent],
    this.center = Alignment.center,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.medium,
  });

  final File file;
  final double radius;
  final List<double> stops;
  final List<Color> colors;
  final Alignment center;
  final BoxFit fit;
  final Alignment alignment;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        return RadialGradient(
          center: center,
          radius: radius,
          colors: colors,
          stops: stops,
          transform: const _AspectRadialTransform(),
        ).createShader(bounds);
      },
      child: Image.file(
        file,
        fit: fit,
        alignment: alignment,
        filterQuality: filterQuality,
      ),
    );
  }
}

class _AspectRadialTransform extends GradientTransform {
  const _AspectRadialTransform();

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final w = bounds.width;
    final h = bounds.height;
    if (w <= 0 || h <= 0) return Matrix4.identity();

    final aspect = w / h;
    var sx = 1.0;
    var sy = 1.0;

    if (aspect > 1.0) {
      sx = aspect;
    } else if (aspect < 1.0) {
      sy = 1.0 / aspect;
    }

    final cx = bounds.left + w / 2;
    final cy = bounds.top + h / 2;

    return Matrix4.identity()
      ..translateByDouble(cx, cy, 0.0, 1.0)
      ..scaleByDouble(sx, sy, 1.0, 1.0)
      ..translateByDouble(-cx, -cy, 0.0, 1.0);
  }
}
