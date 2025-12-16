// lib/core/ui/infinite_ticker.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

@immutable
class TickerItem {
  const TickerItem(
      this.text, {
        this.style = const TextStyle(),
        this.accent = false,
      });

  final String text;
  final TextStyle style;
  final bool accent;
}

class InfiniteTickerBar extends StatefulWidget {
  const InfiniteTickerBar({
    super.key,
    required this.items,

    this.fontSize = 14,
    this.height = 44,
    this.pixelsPerSecond = 60,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),

    // colors
    this.normalColor = const Color(0xB3FFFFFF),
    this.accentColor = const Color(0xFFFF2BD6),
    this.separatorColor = const Color(0x73FFFFFF),

    this.separator,
    this.separatorGap = 18,

    // borders
    this.borderColor = const Color(0xC3B5B5B5),
    this.borderWidth = 2,

    this.reverse = false,

    // NEW:
    this.time,          // seconds
    this.clip = true,   // внутренний ClipRect
  });

  final List<TickerItem> items;

  final double fontSize;
  final double height;
  final double pixelsPerSecond;
  final EdgeInsets padding;

  final Color normalColor;
  final Color accentColor;
  final Color separatorColor;

  final Widget? separator;
  final double separatorGap;

  final Color borderColor;
  final double borderWidth;

  final bool reverse;

  // NEW
  final ValueListenable<double>? time;
  final bool clip;

  @override
  State<InfiniteTickerBar> createState() => _InfiniteTickerBarState();
}

class _InfiniteTickerBarState extends State<InfiniteTickerBar>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;

  final ValueNotifier<double> _internalTime = ValueNotifier<double>(0);
  late ValueListenable<double> _time;

  final GlobalKey _seqKey = GlobalKey();

  double _seqWidth = 0;
  double _viewportWidth = 0;
  int _repeat = 2;

  @override
  void initState() {
    super.initState();

    _time = widget.time ?? _internalTime;

    if (widget.time == null) {
      _ticker = createTicker((elapsed) {
        _internalTime.value = elapsed.inMicroseconds / 1e6;
      })..start();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndUpdate());
  }

  @override
  void didUpdateWidget(covariant InfiniteTickerBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // если переключили источник времени (обычно не нужно, но на hot-reload полезно)
    if (oldWidget.time != widget.time) {
      _ticker?.dispose();
      _ticker = null;
      _internalTime.value = 0;
      _time = widget.time ?? _internalTime;

      if (widget.time == null) {
        _ticker = createTicker((elapsed) {
          _internalTime.value = elapsed.inMicroseconds / 1e6;
        })..start();
      }
    }

    if (oldWidget.items != widget.items ||
        oldWidget.fontSize != widget.fontSize ||
        oldWidget.separatorGap != widget.separatorGap ||
        oldWidget.pixelsPerSecond != widget.pixelsPerSecond ||
        oldWidget.reverse != widget.reverse ||
        oldWidget.normalColor != widget.normalColor ||
        oldWidget.accentColor != widget.accentColor ||
        oldWidget.separatorColor != widget.separatorColor ||
        oldWidget.borderColor != widget.borderColor ||
        oldWidget.borderWidth != widget.borderWidth ||
        oldWidget.separator.runtimeType != widget.separator.runtimeType) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndUpdate());
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _internalTime.dispose();
    super.dispose();
  }

  void _measureAndUpdate() {
    if (!mounted) return;

    final rb = _seqKey.currentContext?.findRenderObject() as RenderBox?;
    final w = rb?.size.width ?? 0;

    if (w <= 0 || widget.items.isEmpty) {
      setState(() {
        _seqWidth = 0;
        _repeat = 1;
      });
      return;
    }

    final viewport = _viewportWidth <= 0 ? 1.0 : _viewportWidth;
    final repeat = (viewport / w).ceil() + 3;

    setState(() {
      _seqWidth = w;
      _repeat = repeat;
    });
  }

  Color _resolveItemColor(TickerItem item) {
    if (item.style.color != null) return item.style.color!;
    return item.accent ? widget.accentColor : widget.normalColor;
  }

  Widget _defaultSeparator() => Icon(
    Icons.add_circle_outline,
    size: 16,
    color: widget.separatorColor,
  );

  Widget _buildSeparator() {
    final sep = widget.separator ?? _defaultSeparator();
    return IconTheme(
      data: IconThemeData(color: widget.separatorColor, size: 16),
      child: sep,
    );
  }

  Widget _sequence({Key? key}) {
    final strut = StrutStyle(
      fontSize: widget.fontSize,
      height: 1.0,
      forceStrutHeight: true,
    );

    final children = <Widget>[];
    for (final it in widget.items) {
      children.add(
        Text(
          it.text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          strutStyle: strut,
          style: it.style.copyWith(
            fontSize: widget.fontSize,
            color: _resolveItemColor(it),
          ),
        ),
      );

      children.add(SizedBox(width: widget.separatorGap));
      children.add(_buildSeparator());
      children.add(SizedBox(width: widget.separatorGap));
    }

    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final vw = c.maxWidth;
        if (vw != _viewportWidth) {
          _viewportWidth = vw;
          WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndUpdate());
        }

        if (widget.items.isEmpty) {
          return SizedBox(height: widget.height);
        }

        final strip = RepaintBoundary(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sequence(key: _seqKey),
              for (int i = 0; i < _repeat - 1; i++) _sequence(),
            ],
          ),
        );

        final animated = AnimatedBuilder(
          animation: _time,
          child: Padding(
            padding: widget.padding,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              clipBehavior: Clip.none,
              child: strip,
            ),
          ),
          builder: (context, child) {
            final base = (_seqWidth <= 0) ? 1.0 : _seqWidth;

            final travel = (_time.value * widget.pixelsPerSecond) % base;
            final rawDx = widget.reverse ? -(base - travel) : -travel;

            final dpr = MediaQuery.of(context).devicePixelRatio;
            final dx = (rawDx * dpr).roundToDouble() / dpr;

            return Transform.translate(
              offset: Offset(dx, 0),
              child: child,
            );
          },
        );

        final content = widget.clip ? ClipRect(child: animated) : animated;

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              top: BorderSide(color: widget.borderColor, width: widget.borderWidth),
              bottom: BorderSide(color: widget.borderColor, width: widget.borderWidth),
            ),
          ),
          child: content,
        );
      },
    );
  }
}
