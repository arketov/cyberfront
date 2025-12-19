// lib/core/ui/equal_height_row.dart
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class EqualHeightRow extends MultiChildRenderObjectWidget {
  EqualHeightRow({
    super.key,
    required Widget left,
    required Widget right,
    this.gap = 12,
    this.leftFlex = 3,
    this.rightFlex = 4,
  }) : super(children: [left, right]);

  final double gap;
  final int leftFlex;
  final int rightFlex;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderEqualHeightRow(
    gap: gap,
    leftFlex: leftFlex,
    rightFlex: rightFlex,
  );

  @override
  void updateRenderObject(BuildContext context, covariant _RenderEqualHeightRow ro) {
    ro
      ..gap = gap
      ..leftFlex = leftFlex
      ..rightFlex = rightFlex;
  }
}

class _PD extends ContainerBoxParentData<RenderBox> {}

class _RenderEqualHeightRow extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _PD>, RenderBoxContainerDefaultsMixin<RenderBox, _PD> {
  _RenderEqualHeightRow({
    required double gap,
    required int leftFlex,
    required int rightFlex,
  })  : _gap = gap,
        _leftFlex = leftFlex,
        _rightFlex = rightFlex;

  double _gap;
  int _leftFlex;
  int _rightFlex;

  set gap(double v) {
    if (_gap == v) return;
    _gap = v;
    markNeedsLayout();
  }

  set leftFlex(int v) {
    if (_leftFlex == v) return;
    _leftFlex = v;
    markNeedsLayout();
  }

  set rightFlex(int v) {
    if (_rightFlex == v) return;
    _rightFlex = v;
    markNeedsLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PD) child.parentData = _PD();
  }

  @override
  void performLayout() {
    final left = firstChild;
    final right = left == null ? null : childAfter(left);
    if (left == null || right == null) {
      size = constraints.constrain(Size.zero);
      return;
    }

    // ширина почти всегда bounded; если нет — лучше пусть падает в zero, чем ломает дерево
    final maxW = constraints.hasBoundedWidth ? constraints.maxWidth : constraints.biggest.width;
    if (!maxW.isFinite) {
      size = constraints.constrain(const Size(0, 0));
      return;
    }

    final totalFlex = math.max(1, _leftFlex + _rightFlex);
    final availW = math.max(0.0, maxW - _gap);
    final leftW = availW * (_leftFlex / totalFlex);
    final rightW = availW - leftW;

    // 1-й проход: меряем высоты
    left.layout(BoxConstraints.tightFor(width: leftW), parentUsesSize: true);
    right.layout(BoxConstraints.tightFor(width: rightW), parentUsesSize: true);

    final h = math.max(left.size.height, right.size.height);

    // 2-й проход: даём одинаковую высоту
    left.layout(BoxConstraints.tightFor(width: leftW, height: h), parentUsesSize: true);
    right.layout(BoxConstraints.tightFor(width: rightW, height: h), parentUsesSize: true);

    (left.parentData as _PD).offset = Offset.zero;
    (right.parentData as _PD).offset = Offset(leftW + _gap, 0);

    size = constraints.constrain(Size(maxW, h));
  }
}
