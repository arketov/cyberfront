// lib/cor/ui/sub_card.dart

import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:flutter/material.dart';

enum SubCardTone { pink, blue }

class _AspectRadialTransform extends GradientTransform {
  const _AspectRadialTransform();

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final w = bounds.width;
    final h = bounds.height;
    if (w <= 0 || h <= 0) return Matrix4.identity();

    final aspect = w / h;

    double sx = 1.0;
    double sy = 1.0;

    if (aspect > 1.0) {
      // шире чем выше -> тянем по X
      sx = aspect;
    } else if (aspect < 1.0) {
      // выше чем шире -> тянем по Y
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

class SubCard extends CardBase {
  const SubCard({
    super.key,
    required this.title,
    required this.value,
    this.tone = SubCardTone.pink,
  });

  final String title;
  final String value;
  final SubCardTone tone;

  static final _pinkBg = const Color(0xFF701055).withValues(alpha: .9);
  static const _pinkStroke = Color(0xFFFF2BD6);

  static final _blueBg = const Color(0xFF0B2C7C).withValues(alpha: .9);
  static const _blueStroke = Color(0xFF1557FF);

  Color get _bg => tone == SubCardTone.pink ? _pinkBg : _blueBg;

  Color get _stroke => tone == SubCardTone.pink ? _pinkStroke : _blueStroke;

  @override
  Color? backgroundColor(BuildContext context) => _bg;

  @override
  bool get backgroundGradientEnabled => false;

  @override
  bool get insetShadowEnabled => false;

  // чтобы линия была от края до края
  @override
  EdgeInsetsGeometry get padding => const EdgeInsets.fromLTRB(5, 14, 5, 16);

  @override
  Gradient? borderGradient(BuildContext context) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0.0, 0.55, 1.0],
      colors: [
        _stroke.withOpacity(.85),
        _stroke.withOpacity(.35),
        _stroke.withOpacity(.20),
      ],
    );
  }

  @override
  Gradient? backgroundGradient(BuildContext context) {
    return RadialGradient(
      center: Alignment.center,
      radius: 1.1,
      focal: Alignment.centerLeft,
      stops: const [0, 0.5, ],
      colors: [
        _bg.withValues(alpha: 1),
        ?Color.lerp(Colors.black, _bg.withValues(alpha: 1), 0.3)
      ],
      transform: const _AspectRadialTransform(),
    );
  }

  @override
  List<BoxShadow> shadows(BuildContext context) => [
    BoxShadow(
      color: _stroke.withOpacity(.18),
      blurRadius: 26,
      spreadRadius: -10,
      offset: const Offset(0, 14),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(.55),
      blurRadius: 22,
      spreadRadius: -14,
      offset: const Offset(0, 16),
    ),
  ];

  @override
  Widget buildContent(BuildContext context) {
    final lineColor = Colors.white.withOpacity(.30);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(child: Container(height: 1, color: lineColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(child: Container(height: 1, color: lineColor)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
