// lib/core/debug/frame_meter.dart
import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class FrameMeter {
  FrameMeter({this.tag = 'FRAME'}) {
    WidgetsBinding.instance.addTimingsCallback(_onTimings);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _flush());
  }

  final String tag;
  final List<FrameTiming> _buf = <FrameTiming>[];
  Timer? _timer;

  void _onTimings(List<FrameTiming> timings) {
    _buf.addAll(timings);
  }

  void _flush() {
    if (_buf.isEmpty) return;

    int usAvg(Iterable<int> xs) => xs.reduce((a, b) => a + b) ~/ xs.length;
    int usMax(Iterable<int> xs) => xs.reduce((a, b) => a > b ? a : b);

    final buildUs = _buf.map((t) => t.buildDuration.inMicroseconds);
    final rasterUs = _buf.map((t) => t.rasterDuration.inMicroseconds);
    final totalUs = _buf.map((t) => t.totalSpan.inMicroseconds);

    final fps = _buf.length;

    debugPrint(
      '$tag fps=$fps '
          'build(avg=${usAvg(buildUs) / 1000.0}ms max=${usMax(buildUs) / 1000.0}ms) '
          'raster(avg=${usAvg(rasterUs) / 1000.0}ms max=${usMax(rasterUs) / 1000.0}ms) '
          'total(max=${usMax(totalUs) / 1000.0}ms)',
    );

    _buf.clear();
  }

  void dispose() {
    WidgetsBinding.instance.removeTimingsCallback(_onTimings);
    _timer?.cancel();
  }
}

