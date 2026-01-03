/// Exception thrown when API calls fail
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() => message;

  /// Check if error is a network connectivity issue
  bool get isNetworkError => statusCode == null;

  /// Check if error is a client error (4xx)
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Check if error is a server error (5xx)
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Check if resource was not found (404)
  bool get isNotFound => statusCode == 404;
}
