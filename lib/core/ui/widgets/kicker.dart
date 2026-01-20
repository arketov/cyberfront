//lib/features/hello/cards/hello_kicker.dart

import 'package:flutter/material.dart';

class Kicker extends StatelessWidget {
  const Kicker(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: color ?? cs.onSurface.withValues(alpha: .55),
      ),
    );
  }
}
