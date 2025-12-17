// lib/core/ui/infinite_ticker.dart
import 'dart:ui' show ImageFilter;
import 'package:cyberdriver/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


enum _TickerSlot { left, center, right }

class _CenterAnchoredDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final c = layoutChild(
      _TickerSlot.center,
      BoxConstraints(maxWidth: double.infinity, maxHeight: size.height),
    );

    final cx = size.width / 2;
    final cy = size.height / 2;

    positionChild(_TickerSlot.center, Offset(cx - c.width / 2, cy - c.height / 2));

    if (hasChild(_TickerSlot.left)) {
      final l = layoutChild(
        _TickerSlot.left,
        BoxConstraints(maxWidth: double.infinity, maxHeight: size.height),
      );
      positionChild(_TickerSlot.left, Offset(cx - c.width / 2 - l.width, cy - l.height / 2));
    }

    if (hasChild(_TickerSlot.right)) {
      final r = layoutChild(
        _TickerSlot.right,
        BoxConstraints(maxWidth: double.infinity, maxHeight: size.height),
      );
      positionChild(_TickerSlot.right, Offset(cx + c.width / 2, cy - r.height / 2));
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
}
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

/// Полностью статическая полоса: НИКАКОЙ анимации/движения.
class InfiniteTickerBar extends StatelessWidget {
  const InfiniteTickerBar({
    super.key,
    required this.items,

    // layout
    this.fontSize = 14,
    this.height = 44,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),

    // colors
    this.normalColor = const Color(0xB3FFFFFF),
    this.accentColor = const Color(0xFFFF2BD6),
    this.separatorColor = const Color(0x73FFFFFF),

    this.separator,
    this.separatorGap = 18,

    // glass/frame
    this.borderRadius = 18,
    this.borderColor = const Color(0x24FFFFFF),
    this.borderWidth = 1,

    // fade edges
    this.fadeWidth = 5,

    this.clip = true,
  });

  final List<TickerItem> items;

  final double fontSize;
  final double height;
  final EdgeInsets padding;

  final Color normalColor;
  final Color accentColor;
  final Color separatorColor;

  final Widget? separator;
  final double separatorGap;

  final double borderRadius;
  final Color borderColor;
  final double borderWidth;

  final double fadeWidth;

  final bool clip;

  Color _resolveItemColor(TickerItem item) {
    if (item.style.color != null) return item.style.color!;
    return item.accent ? accentColor : normalColor;
  }

  Widget _defaultSeparator() =>
      Icon(Icons.add_circle_outline, size: 16, color: separatorColor);

  Widget _buildSeparator() {
    final sep = separator ?? _defaultSeparator();
    return IconTheme(
      data: IconThemeData(color: separatorColor, size: 16),
      child: sep,
    );
  }

  Widget _edgeFade(Widget child) {
    if (fadeWidth <= 0) return child;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        if (w <= 0) return child;

        final fw = fadeWidth.clamp(0.0, w / 2);
        final a = (fw / w).clamp(0.1, 0.5);

        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0.0, a, 1.0 - a, 1.0],
            ).createShader(rect);
          },
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (items.isEmpty) return SizedBox(height: height);
    final strut = StrutStyle( fontSize: fontSize, height: 1.0, forceStrutHeight: true, );
    final iconSize = 16.0;
    final sepSlotW = separatorGap * 2 + iconSize;

    final mid = items.length ~/ 2;
    final leftItems = items.sublist(0, mid);
    final centerItem = items[mid];
    final rightItems = items.sublist(mid + 1);

    Widget buildText(TickerItem it) => Text(
      it.text,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      strutStyle: strut,
      textAlign: TextAlign.center,
      style: it.style.copyWith(
        fontSize: fontSize,
        color: _resolveItemColor(it),
      ),
    );

    Widget sepSlot() => SizedBox(
      width: sepSlotW,
      child: Center(child: _buildSeparator()),
    );

    Widget sideRow(List<TickerItem> list, {required bool leadingSep, required bool trailingSep}) {
      final w = <Widget>[];
      if (leadingSep) w.add(sepSlot());

      for (var i = 0; i < list.length; i++) {
        w.add(buildText(list[i]));
        final isLast = i == list.length - 1;
        if (!isLast || trailingSep) w.add(sepSlot());
      }

      return Row(mainAxisSize: MainAxisSize.min, children: w);
    }

    final body = Padding(
      padding: padding,
      child: SizedBox.expand(
        child: CustomMultiChildLayout(
          delegate: _CenterAnchoredDelegate(),
          children: [
            if (leftItems.isNotEmpty)
              LayoutId(
                id: _TickerSlot.left,
                // слева добавляем separator ПОСЛЕ каждого, включая последний (между left и center)
                child: sideRow(leftItems, leadingSep: false, trailingSep: true),
              ),

            LayoutId(
              id: _TickerSlot.center,
              child: buildText(centerItem),
            ),

            if (rightItems.isNotEmpty)
              LayoutId(
                id: _TickerSlot.right,
                // справа начинаем с separator (между center и первым right)
                child: sideRow(rightItems, leadingSep: true, trailingSep: false),
              ),
          ],
        ),
      ),
    );

    final content = clip ? ClipRect(child: body) : body;
    final faded = _edgeFade(content);

    final radius = BorderRadius.circular(borderRadius);
    final palette = Theme.of(context).extension<AppPalette>()!;
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: palette.blurSigma, sigmaY: palette.blurSigma),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: palette.blurBlack,
              borderRadius: radius,
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Center(child: faded),
          ),
        ),
      ),
    );
  }
}
