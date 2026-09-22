import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/features/auth/sign_in_screen.dart';
import 'package:saints_link/src/router.dart';
import 'package:saints_link/src/widgets/zoom_tab_container.dart';

import '../support/fakes.dart';

/// Every navigation zooms. go_router silently falls back to NoTransitionPage
/// when it fails to recognise the app, and tab switches used to cut, so both
/// are pinned here.
void main() {
  Future<GoRouter> pumpApp(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(PreviewApi()),
        tokenStoreProvider.overrideWithValue(PreviewTokens()),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('a push runs the 300ms zoom transition', (tester) async {
    final router = await pumpApp(tester);
    router.push('/sign-in');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final route = ModalRoute.of(tester.element(find.byType(SignInScreen)))!;
    expect(route.transitionDuration, const Duration(milliseconds: 300));
    expect(route.animation!.value, inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
  });

  testWidgets('a tab switch zooms the incoming tab and keeps the old one', (
    tester,
  ) async {
    Widget app(int index) => MaterialApp(
      home: ZoomTabContainer(
        index: index,
        children: const [Text('one'), Text('two')],
      ),
    );
    await tester.pumpWidget(app(0));
    await tester.pumpWidget(app(1));
    await tester.pump(const Duration(milliseconds: 100));

    double scaleOf(String text) => tester
        .widget<ScaleTransition>(
          find.ancestor(
            of: find.text(text),
            matching: find.byType(ScaleTransition),
          ),
        )
        .scale
        .value;
    expect(scaleOf('two'), inExclusiveRange(0.85, 1));
    expect(scaleOf('one'), inExclusiveRange(1, 1.05));

    await tester.pumpAndSettle();
    expect(scaleOf('two'), 1);
    // The old tab stays mounted, only hidden.
    expect(find.text('one', skipOffstage: false), findsOneWidget);
    expect(find.text('one'), findsNothing);
  });
}
