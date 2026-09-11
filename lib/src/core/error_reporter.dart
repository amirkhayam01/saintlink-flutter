import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Where unexpected failures go.
///
/// A seam, not a service: nothing in the app knows whether reports end up in
/// Sentry, Crashlytics or the debug console. Swapping the destination is one
/// provider override in `main.dart`, and no screen or repository changes.
///
/// What counts as reportable: a failure the customer could not have caused.
/// A 422 is the customer's to fix and is never reported; a 5xx, a timeout, or
/// an exception the framework caught is ours to know about.
abstract class ErrorReporter {
  Future<void> report(Object error, StackTrace? stackTrace, {String? context});

  /// Routes Flutter's own uncaught-error hooks here. Call once at start-up.
  void installGlobalHandlers() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      report(details.exception, details.stack, context: details.library);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      report(error, stack, context: 'platform');

      return true;
    };
  }
}

/// The default: prints to the console and does nothing else.
class ConsoleErrorReporter extends ErrorReporter {
  @override
  Future<void> report(Object error, StackTrace? stackTrace, {String? context}) async {
    developer.log(
      context == null ? '$error' : '[$context] $error',
      name: 'saints_link',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
