/// Custom exception class for typed error handling across the application.
class AppException implements Exception {
  /// Error code (e.g., 'network-error', 'not-found').
  final String code;

  /// Human-readable error message.
  final String message;

  const AppException(this.code, this.message);

  @override
  String toString() => 'AppException($code): $message';
}
