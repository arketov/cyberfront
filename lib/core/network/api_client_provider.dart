import 'package:cyberdriver/core/config/app_config.dart';

import 'network.dart';

/// Builds a REST client using AppConfig (base URL + API version).
RestApiClient createApiClient(AppConfig config) {
  final base = config.apiBaseUrl ?? '';
  final baseUrl = _normalizeBaseUrl('$base/api/${config.apiVersion}/');
  return RestApiClient(
    baseUrl: baseUrl,
    defaultHeaders: const {'accept': 'application/json'},
  );
}

String _normalizeBaseUrl(String url) {
  // Ensure no duplicate slashes except after scheme.
  return url.replaceAllMapped(RegExp(r'(?<!:)//+'), (m) => '/');
}
