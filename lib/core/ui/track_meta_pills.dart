// lib/core/ui/track_meta_pills.dart
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

/// Пилюля вида: "Город  Le Castellet"
/// - label: "Город"
/// - value: "Le Castellet"
/// - clickable + onTap: кликабельность всего чипа
class MetaPill extends StatelessWidget {
  const MetaPill({
    super.key,
    required this.label,
    required this.value,
    this.leading,
    this.color,
    this.clickable = false,
    this.onTap,
    this.height = 30,
    this.radius = 999,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  }) : assert(!clickable || onTap != null, 'If clickable=true, onTap must be provided');

  final String label;
  final String value;

  /// Например кружок "FR" слева. Если не нужен — null.
  final Widget? leading;
  final Color? color;

  final bool clickable;
  final VoidCallback? onTap;

  final double height;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.55),
              height: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ],
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
