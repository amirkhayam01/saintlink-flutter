import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/features/booking/booking_flow_controller.dart';
import 'package:saints_link/src/features/booking/journey_screen.dart';

import '../support/fakes.dart';

Finder field(String hint) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == hint,
);

// With the keyboard up only the first fields show, so a confirm button right
// above the keys invited booking before the flight or notes were ever seen.
void main() {
  testWidgets('the confirm button steps aside while the keyboard is up', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        bookingRepositoryProvider.overrideWithValue(
          FakeBookingRepository()
            ..vehicles = fixtureVehicles()
            ..nextQuote = quoteExpiringIn(const Duration(minutes: 20)),
        ),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(bookingFlowProvider.notifier);
    controller.updateJourney((_) => quotableJourney);
    await controller.requestQuote();
    controller.selectVehicle('saloon-car');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const JourneyScreen(initialStage: JourneyStage.details),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Confirm booking'), findsOneWidget);

    // Tap into the name and raise a keyboard.
    await tester.tap(field('e.g. Ada Lovelace'));
    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(find.textContaining('Confirm booking'), findsNothing);
    expect(find.text('Finish the form to confirm'), findsOneWidget);
    // The total stays in view, so the price is never a surprise.
    expect(find.textContaining('£'), findsOneWidget);

    // The keyboard goes, the button returns.
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(find.textContaining('Confirm booking'), findsOneWidget);
    expect(find.text('Finish the form to confirm'), findsNothing);

    // The last field ends with Done, which drops the keyboard.
    final notes = tester.widget<TextField>(field('Add a note for your driver'));
    expect(notes.textInputAction, TextInputAction.done);
    expect(tester.takeException(), isNull);
  });
}
