import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/api_client.dart';
import 'package:saints_link/src/core/api_exception.dart';
import 'package:saints_link/src/core/error_reporter.dart';
import 'package:saints_link/src/core/token_store.dart';

/// Answers every request with one scripted response, or one scripted failure.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({this.status = 200, this.body = const {}, this.failure});

  final int status;
  final Map<String, dynamic> body;
  final DioExceptionType? failure;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (failure != null) {
      throw DioException(requestOptions: options, type: failure!);
    }

    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _StubTokens implements TokenStore {
  _StubTokens(this.token);

  final String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String token) async {}

  @override
  Future<void> clear() async {}
}

class _RecordingReporter extends ErrorReporter {
  final reports = <String>[];

  @override
  Future<void> report(
    Object error,
    StackTrace? stackTrace, {
    String? context,
  }) async => reports.add('$context');
}

void main() {
  late _RecordingReporter reporter;

  ApiClient client(_StubAdapter adapter, {String? token}) {
    reporter = _RecordingReporter();

    return ApiClient(
      tokens: _StubTokens(token),
      errors: reporter,
      dio: Dio()..httpClientAdapter = adapter,
    );
  }

  test(
    'sends the headers Laravel needs and the bearer token when there is one',
    () async {
      final adapter = _StubAdapter(body: {'ok': true});

      await client(adapter, token: 'abc').get('/me');

      expect(adapter.lastRequest!.headers['Authorization'], 'Bearer abc');
      expect(adapter.lastRequest!.headers['Accept'], 'application/json');
      expect(
        adapter.lastRequest!.headers['X-Requested-With'],
        'XMLHttpRequest',
      );
    },
  );

  test('sends no Authorization header as a guest', () async {
    final adapter = _StubAdapter(body: {});

    await client(adapter).get('/vehicle-categories');

    expect(adapter.lastRequest!.headers.containsKey('Authorization'), isFalse);
  });

  test('a 422 becomes an ApiException with the message and field errors, and is not reported', () async {
    final adapter = _StubAdapter(
      status: 422,
      body: {
        'message': 'The phone field is required.',
        'errors': {
          'phone': ['The phone field is required.'],
        },
      },
    );

    final error = await client(adapter)
        .post('/auth/request-code')
        .then<ApiException?>(
          (_) => null,
          onError: (Object e) => e as ApiException,
        );

    expect(error!.message, 'The phone field is required.');
    expect(error.statusCode, 422);
    expect(error.firstErrorFor('phone'), 'The phone field is required.');
    expect(reporter.reports, isEmpty);
  });

  test('a 401 is flagged as unauthenticated', () async {
    final error =
        await client(
              _StubAdapter(status: 401, body: {'message': 'Unauthenticated.'}),
            )
            .get('/me')
            .then<ApiException?>(
              (_) => null,
              onError: (Object e) => e as ApiException,
            );

    expect(error!.isUnauthenticated, isTrue);
  });

  test('a 5xx is reported and shown as something to retry', () async {
    final error =
        await client(
              _StubAdapter(
                status: 503,
                body: {'message': 'Online payment is temporarily unavailable.'},
              ),
            )
            .post('/bookings/X/payment-intent')
            .then<ApiException?>(
              (_) => null,
              onError: (Object e) => e as ApiException,
            );

    expect(error!.message, 'Online payment is temporarily unavailable.');
    expect(error.isRetryable, isTrue);
    expect(reporter.reports.single, 'api POST /bookings/X/payment-intent');
  });

  test(
    'a connection failure is reported and phrased for the customer',
    () async {
      final error =
          await client(_StubAdapter(failure: DioExceptionType.connectionError))
              .get('/quotes')
              .then<ApiException?>(
                (_) => null,
                onError: (Object e) => e as ApiException,
              );

      expect(error!.message, contains('offline'));
      expect(error.statusCode, isNull);
      expect(error.isRetryable, isTrue);
      expect(reporter.reports, hasLength(1));
    },
  );
}
