/// Generic REST response wrapper with parsed data and raw payload.
class ApiResponse<T> {
  const ApiResponse({
    required this.statusCode,
    required this.data,
    required this.rawBody,
    required this.headers,
  });

  final int statusCode;
  final T data;
  final String rawBody;
  final Map<String, String> headers;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
