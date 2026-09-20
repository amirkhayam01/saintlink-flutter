import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Where failures the customer could not have caused go. Swap the destination in `main.dart`.
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
  Future<void> report(
    Object error,
    StackTrace? stackTrace, {
    String? context,
  }) async {
    developer.log(
      context == null ? '$error' : '[$context] $error',
      name: 'saints_link',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
