// lib/main.dart
import 'bootstrap.dart';
import 'app/app.dart';

void main() {

  assert(() {
    // _meter = FrameMeter(tag: 'APP');
    // debugRepaintRainbowEnabled = true;
    // debugPaintLayerBordersEnabled = true;
    return true;
  }());
  bootstrap(() => const App());
}
