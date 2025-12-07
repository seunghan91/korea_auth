
/// Base exception class for all authentication errors in Open K-Auth.
class AuthException implements Exception {
  /// A machine-readable error code.
  final String code;

  /// A human-readable error message.
  final String message;

  /// The original error object returned by the underlying provider SDK, if any.
  final dynamic originalError;

  const AuthException(this.code, this.message, [this.originalError]);

  @override
  String toString() => 'AuthException($code): $message';
}
