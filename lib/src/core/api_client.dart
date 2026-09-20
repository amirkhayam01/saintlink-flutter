import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'env.dart';
import 'error_reporter.dart';
import 'token_store.dart';

/// The single way this app talks to Saints Link; every failure becomes an [ApiException].
class ApiClient {
  ApiClient({
    required TokenStore tokens,
    required ErrorReporter errors,
    Dio? dio,
  }) : _tokens = tokens, // ignore: prefer_initializing_formals
       _errors = errors, // ignore: prefer_initializing_formals
       _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = Env.apiBaseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      ..headers['Accept'] = 'application/json'
      // Without this Laravel answers validation failures with an HTML redirect.
      ..headers['X-Requested-With'] = 'XMLHttpRequest'
      // Every status is an answer with a customer-readable message; only the network throws.
      ..validateStatus = (status) => status != null;

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
  final ErrorReporter _errors;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => _send(() => _dio.get<dynamic>(path, queryParameters: query));

  Future<Map<String, dynamic>> post(String path, {Object? body}) =>
      _send(() => _dio.post<dynamic>(path, data: body));

  Future<Map<String, dynamic>> patch(String path, {Object? body}) =>
      _send(() => _dio.patch<dynamic>(path, data: body));

  Future<Map<String, dynamic>> delete(String path) =>
      _send(() => _dio.delete<dynamic>(path));

  Future<Map<String, dynamic>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    late final Response<dynamic> response;

    try {
      response = await request();
    } on DioException catch (error, stack) {
      // Every status passes validateStatus, so anything caught here is the
      // network itself — never something the customer did.
      await _errors.report(
        error,
        stack,
        context: _describe(error.requestOptions),
      );

      throw ApiException(_transportMessage(error));
    }

    final body = response.data;
    final map = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final status = response.statusCode!;

    // A non-JSON success is a proxy or captive portal answering for the server.
    final empty = body == null || body == '' || status == 204;
    if (status < 400 && !empty && body is! Map<String, dynamic>) {
      await _errors.report(
        'HTTP $status: non-JSON body',
        StackTrace.current,
        context: _describe(response.requestOptions),
      );

      throw const ApiException(
        'We could not reach Saints Link. Please try again shortly.',
      );
    }

    if (status >= 500) {
      await _errors.report(
        'HTTP $status: ${map['message'] ?? body}',
        StackTrace.current,
        context: _describe(response.requestOptions),
      );
    }

    if (status >= 400) {
      throw ApiException(
        (map['message'] as String?) ??
            'Something went wrong. Please try again.',
        statusCode: response.statusCode,
        fieldErrors: _fieldErrors(map['errors']),
      );
    }

    return map;
  }

  String _describe(RequestOptions request) =>
      'api ${request.method} ${request.path}';

  /// Validation errors arrive as `{"field": ["message", ...]}`.
  Map<String, List<String>> _fieldErrors(Object? errors) {
    if (errors is! Map) return const {};

    return errors.map(
      (key, value) => MapEntry(
        key.toString(),
        value is List
            ? value.map((item) => item.toString()).toList()
            : <String>[value.toString()],
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
