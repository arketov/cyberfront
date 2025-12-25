// lib/core/config/app_config.dart

class AppConfig {
  const AppConfig({
    required this.appName,
    required this.environment,
    required this.apiVersion,
    this.apiBaseUrl,
  });

  final String appName;
  final String environment;
  final String apiVersion;
  final String? apiBaseUrl;

  static const dev = AppConfig(
    appName: 'CyberDriver',
    environment: 'dev',
    apiVersion: 'v1',
    //apiBaseUrl: 'http://127.0.0.1:8000',
    //apiBaseUrl: 'http://192.168.0.107:8000',
    apiBaseUrl: 'http://10.0.2.2:8000',
  );
}
