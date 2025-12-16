// lib/app/no_transition_page_route.dart
import 'package:flutter/material.dart';

class NoTransitionPageRoute<T> extends MaterialPageRoute<T> {
  NoTransitionPageRoute({required super.builder, super.settings});

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return child; // никаких анимаций
  }
}
