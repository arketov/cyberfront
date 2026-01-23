import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger([this.name = 'CyberDriver']);

  final String name;

  void info(String message) {
    developer.log(message, name: name, level: 800);
    debugPrint('[$name] $message');
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: name,
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
    debugPrint('[$name][WARN] $message ${error ?? ''}');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }

  void severe(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
    debugPrint('[$name][SEVERE] $message ${error ?? ''}');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}

const logger = AppLogger();
