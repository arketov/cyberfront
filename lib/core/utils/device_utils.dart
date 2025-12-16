import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

bool isMobile(BuildContext context, {double breakpoint = 700}) {
  final target = defaultTargetPlatform;
  final platformIsMobile =
      target == TargetPlatform.iOS || target == TargetPlatform.android;

  final size = MediaQuery.sizeOf(context);
  final sizeIsMobile = size.shortestSide < breakpoint;

  if (kIsWeb) {
    return sizeIsMobile;
  }

  return platformIsMobile || sizeIsMobile;
}
