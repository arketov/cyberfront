// lib/core/config/app_config.dart

class AppConfig {
  const AppConfig({
    required this.appName,
    required this.environment,
    required this.apiVersion,
    required this.offices,
    this.apiBaseUrl,
  });

  final String appName;
  final String environment;
  final String apiVersion;
  final List<OfficeConfig> offices;
  final String? apiBaseUrl;

  static const dev = AppConfig(
    appName: 'CyberDriver',
    environment: 'dev',
    apiVersion: 'v1',
    offices: [
      OfficeConfig(
        name: 'Куйбыш MAIN',
        appToken:
            '2c5283d4ffdd47e83f860cf0aa016b20caf666bf519e0d50d8e821caa0e6b6d2',
      ),
    ],
    //apiBaseUrl: 'http://127.0.0.1:8000', // desktop
    //apiBaseUrl: 'http://192.168.0.107:8000', // phisic android
    apiBaseUrl: 'http://46.146.13.77:8002/', // emulator android
  );
}

class OfficeConfig {
  const OfficeConfig({
    required this.name,
    required this.appToken,
  });

  final String name;
  final String appToken;
}
