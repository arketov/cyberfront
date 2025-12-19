// lib/main.dart
import 'bootstrap.dart';
import 'app/app.dart';
import 'package:flutter/widgets.dart';
import 'core/debug/frame_meter.dart';
import 'package:flutter/rendering.dart';

FrameMeter? _meter;
void main() {

  assert(() {
    // _meter = FrameMeter(tag: 'APP');
    // debugRepaintRainbowEnabled = true;
    // debugPaintLayerBordersEnabled = true;
    return true;
  }());
  bootstrap(() => const App());
}
