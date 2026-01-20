// lib/core/ui/track_meta_pills.dart
import 'package:flutter/material.dart';

/// Пилюля вида: "Город  Le Castellet"
/// - label: "Город"
/// - value: "Le Castellet"
/// - clickable + onTap: кликабельность всего чипа
enum MetaPillTone { dark, pink, blue }

class MetaPill extends StatelessWidget {
  const MetaPill({
    super.key,
    this.label = '',
    required this.value,
    this.leading,
    this.color,
    this.tone = MetaPillTone.dark,
    this.clickable = false,
    this.onTap,
    this.height = 30,
    this.radius = 999,
    this.valueFontWeight = FontWeight.w900,
    this.contentAlignment = Alignment.center,
    this.wrapAlignment = WrapAlignment.center,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  }) : assert(!clickable || onTap != null, 'If clickable=true, onTap must be provided');

  final String label;
  final String value;

  /// Например кружок "FR" слева. Если не нужен — null.
  final Widget? leading;
  final Color? color;
  final MetaPillTone tone;

  final bool clickable;
  final VoidCallback? onTap;

  final double height;
  final double radius;
  final EdgeInsetsGeometry padding;
  final FontWeight valueFontWeight;
  final Alignment contentAlignment;
  final WrapAlignment wrapAlignment;

  static final _pinkBg = const Color(0xFF300724).withValues(alpha: 1);
  static const _pinkStroke = Color(0xFFCC24A8);

  static final _blueBg = const Color(0xFF08215A).withValues(alpha: .9);
  static const _blueStroke = Color(0xFF1557FF);

  Color _bgColor() {
    if (color != null) return color!;
    switch (tone) {
      case MetaPillTone.pink:
        return _pinkBg;
      case MetaPillTone.blue:
        return _blueBg;
      case MetaPillTone.dark:
        return Colors.black.withValues(alpha: 0.45);
    }
  }

  Color _borderColor() {
    switch (tone) {
      case MetaPillTone.pink:
        return _pinkStroke;
      case MetaPillTone.blue:
        return _blueStroke;
      case MetaPillTone.dark:
        return Colors.white.withValues(alpha: 0.10);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showLabel = label.trim().isNotEmpty;
    final child = Container(
      constraints: BoxConstraints(minHeight: height),
      padding: padding,
      decoration: BoxDecoration(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: _borderColor(),
          width: 1,
        ),
      ),
      child: Align(
        alignment: contentAlignment,
        widthFactor: 1,
        heightFactor: 1,
        child: Wrap(
          alignment: wrapAlignment,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            if (leading != null) leading!,
            if (showLabel)
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.55),
                  height: 1.0,
                ),
              ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: valueFontWeight,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );

    if (!clickable) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}
