import 'dart:async';
import 'package:flutter/material.dart';

import 'core/utils/logger.dart';

void bootstrap(Widget Function() builder) {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    logger.info('Starting app');
    runApp(builder());
  }, (error, stackTrace) {
    logger.severe('Uncaught error', error, stackTrace);
  });
}
