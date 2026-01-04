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
    //apiBaseUrl: 'http://127.0.0.1:8000', // desktop
    //apiBaseUrl: 'http://192.168.0.107:8000', // phisic android
    apiBaseUrl: 'http://46.146.94.18:8002/', // emulator android
  );
}
