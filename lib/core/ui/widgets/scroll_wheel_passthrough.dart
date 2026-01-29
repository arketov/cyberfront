import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class ScrollWheelPassthrough extends StatelessWidget {
  const ScrollWheelPassthrough({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (signal) {
        if (!enabled) return;
        if (signal is! PointerScrollEvent) return;
        final scrollable = Scrollable.of(context);
        if (scrollable == null) return;
        final position = scrollable.position;
        final target = (position.pixels + signal.scrollDelta.dy)
            .clamp(position.minScrollExtent, position.maxScrollExtent);
        if (target != position.pixels) {
          position.jumpTo(target);
        }
      },
      child: child,
    );
  }
}
