import 'dart:developer' as developer;

class AppLogger {
  const AppLogger([this.name = 'CyberDriver']);

  final String name;

  void info(String message) => developer.log(
        message,
        name: name,
        level: 800,
      );

  void warning(String message, [Object? error, StackTrace? stackTrace]) => developer.log(
        message,
        name: name,
        level: 900,
        error: error,
        stackTrace: stackTrace,
      );

  void severe(String message, [Object? error, StackTrace? stackTrace]) => developer.log(
        message,
        name: name,
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
}

const logger = AppLogger();
