// lib/core/ui/stretch_ticker_header.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'infinite_ticker.dart';

class StretchTickerHeader extends StatefulWidget {
  const StretchTickerHeader({
    super.key,
    required this.items,

    this.baseHeight = 44,
    this.maxStretch = 140,
    this.maxAngleDeg = 28,

    this.pixelsPerSecond = 60,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),

    this.normalColor = const Color(0xB3FFFFFF),
    this.accentColor = const Color(0xFFFF2BD6),
    this.separatorColor = const Color(0x73FFFFFF),

    this.separator,
    this.separatorGap = 18,

    this.borderColor = const Color(0x24FFFFFF),
    this.borderWidth = 1,
  });

  final List<TickerItem> items;

  final double baseHeight;
  final double maxStretch;
  final double maxAngleDeg;

  final double pixelsPerSecond;
  final EdgeInsets padding;

  final Color normalColor;
  final Color accentColor;
  final Color separatorColor;

  final Widget? separator;
  final double separatorGap;

  final Color borderColor;
  final double borderWidth;

  @override
  State<StretchTickerHeader> createState() => _StretchTickerHeaderState();
}

class _StretchTickerHeaderState extends State<StretchTickerHeader>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<double> _time = ValueNotifier<double>(0);

  double? _restHeight; // “высота покоя” (без стретча)

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _time.value = elapsed.inMicroseconds / 1e6;
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.biggest.height;

        // фиксируем "нормальную" высоту один раз
        if (_restHeight == null || h < _restHeight! - 0.5) {
          _restHeight = h;
        }

        final extra = (h - _restHeight!).clamp(0.0, widget.maxStretch);
        final t = widget.maxStretch <= 0 ? 0.0 : (extra / widget.maxStretch);
        final eased = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));

        final angle = (widget.maxAngleDeg * eased) * math.pi / 180.0;
        final showSecond = eased > 0.001; // без анимации появления

        Widget bar(bool reverse) => InfiniteTickerBar(
          items: widget.items,
          height: widget.baseHeight,
          pixelsPerSecond: widget.pixelsPerSecond,
          padding: widget.padding,
          normalColor: widget.normalColor,
          accentColor: widget.accentColor,
          separatorColor: widget.separatorColor,
          separator: widget.separator,
          separatorGap: widget.separatorGap,
          borderWidth: 0,   // бордер рисуем только снаружи
          reverse: reverse,
          time: _time,      // один таймер на оба тикера
          clip: false,      // не режем внутри
        );

        return SizedBox.expand( // <<< КЛЮЧЕВОЕ: занимает всю высоту sliver-а
          child: DecoratedBox(
            decoration: BoxDecoration(
            ),
            child: ClipRect(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Offstage(
                    offstage: !showSecond,
                    child: Transform.rotate(angle: -angle, child: bar(false)),
                  ),
                  Transform.rotate(angle: angle, child: bar(true)),

                  // держим ВТОРОЙ тикер всегда в дереве (чтобы успел промериться и был “бесконечным” сразу),
                  // но не рисуем пока не начался стретч

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
