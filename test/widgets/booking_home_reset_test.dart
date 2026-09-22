import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/domain/customer.dart';
import 'package:saints_link/src/features/booking/booking_flow_controller.dart';
import 'package:saints_link/src/domain/place.dart';
import 'package:saints_link/src/features/booking/journey_draft.dart';
import 'package:saints_link/src/features/auth/auth_controller.dart';
import 'package:saints_link/src/features/places/recent_places.dart';
import 'package:saints_link/src/router.dart';

import '../support/fakes.dart';

void main() {
  // The form pushes over the shell, so back is the only way home.
  testWidgets('returning Home resets booking', (tester) async {
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
    router.push('/book');
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
    expect(find.text('Plan a journey'), findsNothing);
    expect(find.text('Our services'), findsOneWidget);
    final state = container.read(bookingFlowProvider);
    expect(state.journey, const JourneyDraft());
    expect(state.quote, isNull);
    expect(state.vehicles, isNotEmpty);
    expect(state.fieldErrors, isEmpty);
    router.push('/book');
    await tester.pumpAndSettle();
    expect(find.text('PICKUP ADDRESS'), findsOneWidget);
    expect(find.text('DESTINATION'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // go_router reports a pop without notifying its route listeners, so a
  // reset keyed on the URL never saw the system back gesture.
  testWidgets('system back from the form drops the pickup and stops', (
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
    router.push('/book');
    await tester.pumpAndSettle();
    container
        .read(bookingFlowProvider.notifier)
        .updateJourney(
          (j) => j.copyWith(
            pickup: quotableJourney.pickup,
            via: [const PlaceSelection(address: 'Winchester')],
          ),
        );
    await tester.pumpAndSettle();
    expect(find.text('Southampton Central Station'), findsOneWidget);

    // The Android back gesture, not the on-screen button.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Our services'), findsOneWidget);
    expect(container.read(bookingFlowProvider).journey, const JourneyDraft());

    router.push('/book');
    await tester.pumpAndSettle();
    expect(find.text('Southampton Central Station'), findsNothing);
    expect(find.text('Winchester'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a Recent on Home opens a fresh destination-only form', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        bookingRepositoryProvider.overrideWithValue(
          FakeBookingRepository()..vehicles = fixtureVehicles(),
        ),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        recentPlacesProvider.overrideWith(_HeathrowRecent.new),
        customerPlacesProvider.overrideWith(
          (ref) async => const <PlaceSelection>[],
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(authControllerProvider.notifier)
        .completeSignIn(
          const Customer(
            id: 1,
            name: 'Alex Morgan',
            firstName: 'Alex',
            phone: '+447700900123',
            maskedPhone: '+44 7700 900123',
            marketingConsent: false,
          ),
        );
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
    await tester.tap(find.text('Heathrow Airport'));
    await tester.pumpAndSettle();
    final journey = container.read(bookingFlowProvider).journey;
    expect(journey.pickup.isEmpty, isTrue);
    expect(journey.dropoff.address, 'Heathrow Airport');
    expect(journey.dropoff.isLocated, isTrue);
    expect(journey.pickupDate, isNull);
    expect(journey.passengerCount, 1);
    expect(tester.takeException(), isNull);
  });
}

class _HeathrowRecent extends RecentPlaces {
  @override
  Future<List<PlaceSelection>> build() async => const [
    PlaceSelection(
      address: 'Heathrow Airport',
      latitude: 51.4700,
      longitude: -0.4543,
    ),
  ];
}
