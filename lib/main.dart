import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/core/error_reporter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // To ship crash reporting, construct the real reporter here and pass it to
  // both `installGlobalHandlers` and an `errorReporterProvider` override.
  ConsoleErrorReporter().installGlobalHandlers();

  runApp(const ProviderScope(child: SaintsLinkApp()));
}
