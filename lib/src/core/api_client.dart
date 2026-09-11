import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'env.dart';
import 'token_store.dart';

/// The single way this app talks to Saints Link.
///
/// Every response shape and every failure mode is normalised here, so screens
/// deal in models and [ApiException] rather than in status codes and raw maps.
class ApiClient {
  ApiClient({required TokenStore tokens, Dio? dio})
      : _tokens = tokens, // ignore: prefer_initializing_formals
        _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = Env.apiBaseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      ..headers['Accept'] = 'application/json'
      /*
       * Laravel decides between a redirect and a JSON error from this header.
       * Without it a validation failure on an unauthenticated route comes back
       * as an HTML login redirect, which the app cannot read at all.
       */
      ..headers['X-Requested-With'] = 'XMLHttpRequest'
      // 4xx are answers, not transport failures: they carry the message the
      // customer needs to see, so they are handled rather than thrown by Dio.
      ..validateStatus = (status) => status != null && status < 500;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokens.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStore _tokens;

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: query));

  Future<Map<String, dynamic>> post(String path, {Object? body}) =>
      _send(() => _dio.post<dynamic>(path, data: body));

  Future<Map<String, dynamic>> patch(String path, {Object? body}) =>
      _send(() => _dio.patch<dynamic>(path, data: body));

  Future<Map<String, dynamic>> _send(Future<Response<dynamic>> Function() request) async {
    late final Response<dynamic> response;

    try {
      response = await request();
    } on DioException catch (error) {
      throw ApiException(_transportMessage(error));
    }

    final body = response.data;
    final map = body is Map<String, dynamic> ? body : <String, dynamic>{};

    if (response.statusCode != null && response.statusCode! >= 400) {
      throw ApiException(
        (map['message'] as String?) ?? 'Something went wrong. Please try again.',
        statusCode: response.statusCode,
        fieldErrors: _fieldErrors(map['errors']),
      );
    }

    return map;
  }

  /// Validation errors arrive as `{"field": ["message", ...]}`.
  Map<String, List<String>> _fieldErrors(Object? errors) {
    if (errors is! Map) return const {};

    return errors.map(
      (key, value) => MapEntry(
        key.toString(),
        value is List ? value.map((item) => item.toString()).toList() : <String>[value.toString()],
      ),
    );
  }

  /// Network-level failures, phrased as something the customer can act on.
  String _transportMessage(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'The connection timed out. Please check your signal and try again.',
      DioExceptionType.connectionError =>
        'You appear to be offline. Please check your connection and try again.',
      _ => 'We could not reach Saints Link. Please try again shortly.',
    };
  }
}
