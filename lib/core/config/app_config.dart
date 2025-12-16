// lib/core/config/app_config.dart

class AppConfig {
  const AppConfig({
    required this.appName,
    required this.environment,
    this.apiBaseUrl,
  });

  final String appName;
  final String environment;
  final String? apiBaseUrl;

  static const dev = AppConfig(
    appName: 'CyberDriver',
    environment: 'dev',
  );
}
