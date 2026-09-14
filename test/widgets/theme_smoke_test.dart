import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/features/auth/auth_controller.dart';
import 'package:saints_link/src/features/auth/sign_in_screen.dart';
import 'package:saints_link/src/features/booking/journey_screen.dart';
import 'package:saints_link/src/features/home/home_screen.dart';
import 'package:saints_link/src/widgets/common.dart';

import '../support/fakes.dart';

/// Every screen must build on both grounds: a colour read from the wrong
/// place shows up here as a missing theme extension or a const error, not on
/// a customer's phone with dark mode on.
void main() {
  Widget app(Widget home, ThemeData theme) => ProviderScope(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(FakeBookingRepository()..vehicles = fixtureVehicles()),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: MaterialApp(theme: theme, home: home),
      );

  for (final (name, theme) in [('light', AppTheme.light()), ('dark', AppTheme.dark())]) {
    group(name, () {
      testWidgets('home screen', (tester) async {
        await tester.pumpWidget(app(const HomeScreen(), theme));
        await tester.pumpAndSettle();

        expect(find.text('Where can we take you?'), findsOneWidget);
        expect(find.text('Our services'), findsOneWidget);
        expect(find.text('Popular fixed fares'), findsOneWidget);
        expect(find.textContaining('Good '), findsOneWidget);

        // The theme toggle sits on the hero and offers the other mode.
        final toggle = theme.brightness == Brightness.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded;
        expect(find.byIcon(toggle), findsOneWidget);
      });

      testWidgets('journey screen', (tester) async {
        await tester.pumpWidget(app(const JourneyScreen(), theme));
        await tester.pump();

        expect(find.text('Continue'), findsOneWidget);
        expect(find.text('Add a stop'), findsOneWidget);
      });

      testWidgets('sign-in screen', (tester) async {
        await tester.pumpWidget(app(const SignInScreen(), theme));
        await tester.pump();

        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('shared widgets', (tester) async {
        await tester.pumpWidget(app(
          const Scaffold(
            body: Column(children: [
              ErrorNotice('Something went wrong'),
              DetailRow('Total', '£125.00'),
              StatusChip(label: 'Confirmed', status: 'confirmed'),
              FilledButton(onPressed: null, child: ButtonSpinner()),
            ]),
            bottomNavigationBar: BottomAction(child: SizedBox(height: 40)),
          ),
          theme,
        ));

        expect(find.text('Something went wrong'), findsOneWidget);
      });
    });
  }

  test('the auth state a guest starts in does not block the router', () {
    expect(const AuthState.guest().isRestoring, isFalse);
  });
}
