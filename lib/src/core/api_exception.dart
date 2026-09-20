/// A failure with a message the customer can be shown, as the API wrote it.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
  });

  final String message;
  final int? statusCode;

  /// Per-field validation messages from a 422, keyed by the API's field name.
  final Map<String, List<String>> fieldErrors;

  /// The caller's token is missing, expired or revoked; the app should return
  /// the customer to the sign-in screen rather than showing an error.
  bool get isUnauthenticated => statusCode == 401;

  /// Nothing is wrong with the request — the service is simply unavailable, so
  /// retrying later is worthwhile in a way that a 422 never is.
  bool get isRetryable => statusCode == null || statusCode! >= 500;

  String? firstErrorFor(String field) => fieldErrors[field]?.firstOrNull;

  @override
  String toString() => message;
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
