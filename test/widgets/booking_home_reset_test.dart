import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/features/booking/booking_flow_controller.dart';
import 'package:saints_link/src/features/booking/journey_draft.dart';
import 'package:saints_link/src/router.dart';

import '../support/fakes.dart';

void main() {
  /*
   * The form is pushed over the shell, so the only way back to Home from
   * inside it is the back arrow — there is no tab bar underneath to tap.
   * Two doors in: the "Plan a journey" button, and a direct route push.
   */
  for (final viaButton in [true, false]) {
    testWidgets(
      'returning Home resets booking, entered via ${viaButton ? 'the button' : 'the route'}',
      (tester) async {
        final repository = FakeBookingRepository()
          ..vehicles = fixtureVehicles()
          ..nextQuote = quoteExpiringIn(const Duration(minutes: 20));
        final container = ProviderContainer(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(repository),
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
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
        if (viaButton) {
          await tester.tap(find.text('Plan a journey'));
        } else {
          router.push('/book');
        }
        await tester.pumpAndSettle();
        expect(find.text('PICKUP ADDRESS'), findsOneWidget);
        final controller = container.read(bookingFlowProvider.notifier);
        controller.updateJourney(
          (_) => quotableJourney.copyWith(
            passengerCount: 4,
            luggageCount: 3,
            outboundFlightNumber: 'BA123',
          ),
        );
        await controller.requestQuote();
        await tester.pumpAndSettle();
        expect(container.read(bookingFlowProvider).quote, isNotNull);
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        // Back on Home, with the tabs and no Book among them.
        expect(find.text('Trips'), findsOneWidget);
        expect(find.text('Book'), findsNothing);
        final state = container.read(bookingFlowProvider);
        expect(state.journey, const JourneyDraft());
        expect(state.quote, isNull);
        expect(state.vehicles, isNotEmpty);
        expect(state.fieldErrors, isEmpty);
        await tester.tap(find.text('Plan a journey'));
        await tester.pumpAndSettle();
        expect(find.text('PICKUP ADDRESS'), findsOneWidget);
        expect(find.text('DESTINATION'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Home airport shortcut opens a fresh destination-only form', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        bookingRepositoryProvider.overrideWithValue(
          FakeBookingRepository()..vehicles = fixtureVehicles(),
        ),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
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
    container
        .read(bookingFlowProvider.notifier)
        .updateJourney((_) => quotableJourney);
    await tester.tap(find.text('Heathrow (LHR)'));
    await tester.pumpAndSettle();
    final journey = container.read(bookingFlowProvider).journey;
    expect(journey.pickup.isEmpty, isTrue);
    /*
     * The server's own name for the place, from the one shortcut list, rather
     * than a second hand-written spelling of it. The coordinates are the
     * app's: the server places the name from its own catalogue.
     */
    expect(journey.dropoff.address, 'Heathrow Airport');
    expect(journey.dropoff.isLocated, isTrue);
    expect(journey.pickupDate, isNull);
    expect(journey.passengerCount, 1);
    expect(tester.takeException(), isNull);
  });
}
