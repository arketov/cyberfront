// lib/features/hello/cards/card_base.dart
import 'dart:math' as math;
import 'package:cyberdriver/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class CardBase extends StatelessWidget {
  const CardBase({super.key});

  /// Внутренние отступы контента.
  EdgeInsetsGeometry get padding => const EdgeInsets.fromLTRB(16, 14, 18, 16);

  /// Радиус всех карт.
  BorderRadius get radius => BorderRadius.circular(20);

  /// Фон карты (как у тебя было).
  Color? backgroundColor(BuildContext context) => Colors.black.withValues(alpha: 0.97);
  /// Ширина обводки.
  double get borderWidth => 1;

  /// Явная граница (если нужно переопределить отрисовку бордера).
  BoxBorder? border(BuildContext context) => null;

  /// Весьма аккуратно: карточка кликабельна только если onTap != null.
  VoidCallback? onTap(BuildContext context) => null;

  /// Визуальная обратная связь при тапе (по умолчанию выключена, чтобы ничего не “поехало” в дизайне).
  bool get tapFeedbackEnabled => false;

  bool get backgroundGradientEnabled => true;

  /// Градиент обводки (если null — будет обычный цвет).
  Gradient? borderGradient(BuildContext context) {
    if (!backgroundGradientEnabled) return null;
    final pal = Theme.of(context).extension<AppPalette>();
    if (pal == null) return null;

    Color tone(Color c, {required double mixToBg, required double alpha}) {
      final mixed = Color.lerp(c, pal.bg, mixToBg)!;
      return mixed.withValues(alpha: alpha);
    }

    final pink = tone(pal.pink, mixToBg: 0.22, alpha: 0.5);
    final blue = tone(pal.blue, mixToBg: 0.22, alpha: 0.5);

    const cycles = 3;
    final segments = cycles * 2;

    final colors = <Color>[];
    final stops = <double>[];
    for (var i = 0; i <= segments; i++) {
      colors.add(i.isEven ? pink : blue);
      stops.add(i / segments);
    }

    final seed = Object.hash(runtimeType, key, identityHashCode(this));
    final rnd = math.Random(seed);
    final rotation = (0.3 * 2 - 1) * 0.6;

    return SweepGradient(
      center: Alignment.center,
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: colors,
      stops: stops,
      transform: GradientRotation(rotation),
    );
  }


  Gradient? backgroundGradient(BuildContext context) {
    final bg = (backgroundColor(context) ?? Colors.black);

    // насколько “прозрачнее” углы (0.0..1.0). 0.82 = слегка прозрачные
    final cornerAlpha = (bg.a * 0.82).clamp(0.0, 1.0);
    final midAlpha = bg.a.clamp(0.0, 1.0);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        bg.withValues(alpha: cornerAlpha), // верх-лево
        bg.withValues(alpha: midAlpha),    // центр плотнее
        bg.withValues(alpha: cornerAlpha), // низ-право
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// Цвет обводки, если borderGradient == null
  Color borderColor(BuildContext context) => Colors.white.withOpacity(.12);

  /// Внешняя тень (если надо).
  List<BoxShadow> shadows(BuildContext context) => const [];

  /// Внутренняя тень/подсветка.
  bool get insetShadowEnabled => true;

  /// Контент карты.
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final rOuter = radius;
    final bw = borderWidth;
    final rInner = _deflateBorderRadius(rOuter, bw);

    final g = borderGradient(context);
    final tap = onTap(context);
    final bgGrad = backgroundGradient(context);
    final customBorder = border(context);


    Widget core = DecoratedBox(
      // “рамка” — тут живёт градиент обводки
      decoration: BoxDecoration(
        borderRadius: rOuter,
        border: customBorder,
        gradient: g,
        color: g == null ? borderColor(context) : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(bw),
        child: ClipRRect(
          borderRadius: rInner,
          child: DecoratedBox(
            // “тело” карты — фон
            decoration: BoxDecoration(
              borderRadius: rInner,
              gradient: bgGrad,
              color: bgGrad == null ? backgroundColor(context) : null,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: padding,
                  child: buildContent(context),
                ),

                if (insetShadowEnabled) ...[
                  // Белая херня
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: rInner,
                          gradient: RadialGradient(
                            radius: 1.7,
                            center: Alignment.topLeft,
                            stops: const [0.0, 0.5],
                            colors: [
                              Colors.white.withOpacity(.12),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  //Чёрная херня
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: rInner,
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 2,
                            stops: const [0, 1],
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // Делаем кликабельной ВСЮ карточку, но тени не трогаем (они снаружи)
    if (tap != null) {
      core = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: tap,
            customBorder: RoundedRectangleBorder(borderRadius: rOuter),
            splashFactory:
            tapFeedbackEnabled ? InkSparkle.splashFactory : NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: core,
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: rOuter,
        boxShadow: shadows(context),
      ),
      child: ClipRRect(
        borderRadius: rOuter,
        child: core,
      ),
    );
  }

  static BorderRadius _deflateBorderRadius(BorderRadius r, double d) {
    Radius def(Radius a) => Radius.elliptical(
      math.max(0, a.x - d),
      math.max(0, a.y - d),
    );

    return BorderRadius.only(
      topLeft: def(r.topLeft),
      topRight: def(r.topRight),
      bottomLeft: def(r.bottomLeft),
      bottomRight: def(r.bottomRight),
    );
  }
}
