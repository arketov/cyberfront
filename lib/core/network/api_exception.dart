import 'dart:io';

/// Thrown when a REST call returns a non-success status code.
class ApiException extends HttpException {
  ApiException({
    required this.statusCode,
    required String message,
    this.body = '',
    Uri? uri,
  }) : super(message, uri: uri);

  final int statusCode;
  final String body;

  @override
  String toString() =>
      'ApiException(status: $statusCode, message: $message, uri: $uri)';
}
