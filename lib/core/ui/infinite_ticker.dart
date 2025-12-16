// lib/core/ui/infinite_ticker.dart
import 'package:flutter/material.dart';

@immutable
class TickerItem {
  const TickerItem(
      this.text, {
        this.style = const TextStyle(),
        this.accent = false,
      });

  final String text;

  /// Стиль БЕЗ fontSize (он задаётся у виджета).
  /// Можно задавать weight/letterSpacing/семейство и т.д.
  final TextStyle style;

  /// true -> красим в accentColor (если в style.color не задано)
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

    // Цвета
    this.normalColor = const Color(0xB3FFFFFF),
    this.accentColor = const Color(0xFFFF2BD6),
    this.separatorColor = const Color(0x73FFFFFF),

    // Разделитель
    this.separator,
    this.separatorGap = 18,

    // Границы (серые линии)
    this.borderColor = const Color(0x24FFFFFF),
    this.borderWidth = 1,

    // Направление
    this.reverse = false,
  });

  final List<TickerItem> items;

  final double fontSize;
  final double height;
  final double pixelsPerSecond;
  final EdgeInsets padding;

  final Color normalColor;
  final Color accentColor;
  final Color separatorColor;

  /// Если не задан — будет "плюс в кружке"
  final Widget? separator;
  final double separatorGap;

  final Color borderColor;
  final double borderWidth;

  final bool reverse;

  @override
  State<InfiniteTickerBar> createState() => _InfiniteTickerBarState();
}

class _InfiniteTickerBarState extends State<InfiniteTickerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  final GlobalKey _seqKey = GlobalKey();

  double _seqWidth = 0;
  double _viewportWidth = 0;
  int _repeat = 2;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndStart());
  }

  @override
  void didUpdateWidget(covariant InfiniteTickerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
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
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndStart());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _measureAndStart() {
    if (!mounted) return;

    final rb = _seqKey.currentContext?.findRenderObject() as RenderBox?;
    final w = rb?.size.width ?? 0;

    if (w <= 0 || widget.items.isEmpty) {
      _ctrl.stop();
      setState(() {
        _seqWidth = 0;
        _repeat = 1;
      });
      return;
    }

    final viewport = _viewportWidth <= 0 ? 1.0 : _viewportWidth;
    final repeat = (viewport / w).ceil() + 2;

    final durationMs =
    ((w / widget.pixelsPerSecond) * 1000).round().clamp(1, 1 << 31);

    setState(() {
      _seqWidth = w;
      _repeat = repeat;
    });

    _ctrl
      ..stop()
      ..duration = Duration(milliseconds: durationMs)
      ..repeat();
  }

  Widget _defaultSeparator() {
    return Icon(Icons.add_circle_outline, size: 16, color: widget.separatorColor);
  }

  Widget _buildSeparator() {
    final sep = widget.separator ?? _defaultSeparator();

    // Перекрашиваем separatorColor даже если передали Icon без цвета
    return IconTheme(
      data: IconThemeData(color: widget.separatorColor, size: 16),
      child: sep,
    );
  }

  Color _resolveItemColor(TickerItem item) {
    if (item.style.color != null) return item.style.color!;
    return item.accent ? widget.accentColor : widget.normalColor;
  }

  Widget _sequence({Key? key}) {
    // Делаем "ровно": фиксируем метрики строки
    final strut = StrutStyle(
      fontSize: widget.fontSize,
      height: 1.0,
      forceStrutHeight: true,
    );

    final children = <Widget>[];
    for (int i = 0; i < widget.items.length; i++) {
      final it = widget.items[i];

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

      // ✅ Разделитель после КАЖДОГО элемента, включая последний (чтобы на стыке тоже был)
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
          WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndStart());
        }

        if (widget.items.isEmpty) {
          return SizedBox(height: widget.height);
        }

        // Первый sequence рисуем с key, чтобы измерить реальную ширину
        final first = _sequence(key: _seqKey);

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: widget.borderColor, width: widget.borderWidth),
              bottom: BorderSide(color: widget.borderColor, width: widget.borderWidth),
            ),
          ),
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final base = _seqWidth <= 0 ? 1.0 : _seqWidth;
                final t = _ctrl.value * base;
                final dx = widget.reverse ? t : -t;

                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: UnconstrainedBox(
                    alignment: Alignment.centerLeft,
                    constrainedAxis: Axis.vertical, // высоту оставляем под контролем контейнера
                    child: Padding(
                      padding: widget.padding,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          first,
                          for (int i = 0; i < _repeat - 1; i++) _sequence(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
