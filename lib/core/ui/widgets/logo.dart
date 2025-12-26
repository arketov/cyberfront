// lib/core/ui/logo.dart
import 'package:flutter/material.dart';
import 'package:cyberdriver/core/theme/app_theme.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
    this.size = 22,
    this.cyber = 'КИБЕР',
    this.vodily = 'ВОДИЛЫ',
    this.cyberColor,
    this.vodilyColor,
    this.letterSpacing = -1,
    this.gap = 0,
    this.uppercase = true,

    // ✅ Сжатие/растяжение лого
    this.scaleX = 1.0,
    this.scaleY = 0.9,
    this.alignment = Alignment.centerLeft,
  });

  final double size;
  final String cyber;
  final String vodily;
  final Color? cyberColor;
  final Color? vodilyColor;
  final double letterSpacing;
  final double gap;
  final bool uppercase;

  final double scaleX;
  final double scaleY;
  final Alignment alignment;

  static const String _ffBlack = 'TTTravelsNextBlack';
  static const String _ffOutline = 'TTTravelsNextBlackOutline';

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final c1 = Colors.white;
    final c2 = vodilyColor ?? palette.pink;

    final t1 = uppercase ? cyber.toUpperCase() : cyber;
    final t2 = uppercase ? vodily.toUpperCase() : vodily;

    final rich = RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: t1,
            style: TextStyle(
              fontFamily: _ffOutline,
              fontSize: size,
              height: 1,
              letterSpacing: letterSpacing,
              color: c1,
            ),
          ),
          if (gap > 0)
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: SizedBox(width: gap),
            ),
          TextSpan(
            text: t2,
            style: TextStyle(
              fontFamily: _ffBlack,
              fontSize: size,
              height: 1,
              letterSpacing: letterSpacing,
              color: c2,
            ),
          ),
        ],
      ),
    );

    return rich;
  }
}
