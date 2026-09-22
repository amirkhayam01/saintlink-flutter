import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/core/formatting.dart';
import 'package:saints_link/src/domain/place.dart';
import 'package:saints_link/src/features/booking/booking_flow_controller.dart';
import 'package:saints_link/src/features/booking/journey_screen.dart';
import 'package:saints_link/src/features/places/current_location.dart';

import '../support/fakes.dart';

/// The field a caption names, via the control's semantics label.
Finder fieldNamed(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == label,
  ),
  matching: find.byType(InputDecorator),
);

/// The form is a sheet over a map now; on the default 800x600 test window
/// its lower half is off-screen and taps there land on nothing.
void phoneSized(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'booking with return and flight fits a narrow screen: dark $dark, scale $scale',
        (tester) async {
          tester.view.physicalSize = const Size(320, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final container = ProviderContainer(
            overrides: [
              bookingRepositoryProvider.overrideWithValue(
                FakeBookingRepository()..vehicles = fixtureVehicles(),
              ),
            ],
          );
          addTearDown(container.dispose);
          container
              .read(bookingFlowProvider.notifier)
              .updateJourney(
                (_) => quotableJourney.copyWith(
                  isReturn: true,
                  returnDate: DateTime(2026, 10, 5),
                  returnTime: const TimeOfDay(hour: 14, minute: 0),
                  outboundFlightNumber: 'BA123',
                  outboundTerminal: 'T5',
                ),
              );
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                theme: dark ? AppTheme.dark() : AppTheme.light(),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: const JourneyScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          for (var i = 0; i < 8; i++) {
            await tester.drag(find.byType(ListView), const Offset(0, -300));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  }

  testWidgets('the form asks for the route first and the date second', (
    tester,
  ) async {
    phoneSized(tester);
    final container = ProviderContainer(
      overrides: [
        bookingRepositoryProvider.overrideWithValue(
          FakeBookingRepository()..vehicles = fixtureVehicles(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const JourneyScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Stage one: the route, and nothing else. No date yet, no way on
    // until both ends are named.
    expect(find.text('Plan your journey'), findsOneWidget);
    expect(find.text('PICKUP DATE & TIME'), findsNothing);
    for (final label in ['Pickup address', 'Destination']) {
      final field = fieldNamed(label);
      expect(tester.widget<InputDecorator>(field).isEmpty, isTrue);
      expect(find.text(label.toUpperCase()), findsOneWidget);
    }
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isFalse,
    );

    container
        .read(bookingFlowProvider.notifier)
        .updateJourney(
          (j) => j.copyWith(
            pickup: quotableJourney.pickup,
            dropoff: quotableJourney.dropoff,
          ),
        );
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isTrue,
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Stage two: the route as a summary, and what the price depends on.
    expect(find.text('When are you travelling?'), findsOneWidget);
    expect(find.text('PICKUP ADDRESS'), findsNothing);
    expect(find.text(quotableJourney.pickup.address), findsOneWidget);
    expect(find.text('PICKUP DATE & TIME'), findsOneWidget);
    final dateField = fieldNamed('Pickup date & time');
    expect(tester.widget<InputDecorator>(dateField).isEmpty, isTrue);
    // Without a date the button names the gap and opens the picker itself,
    // rather than sitting greyed out under the louder switch and steppers.
    expect(find.text('See prices'), findsNothing);
    expect(find.text('Choose a date to see prices'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isTrue,
    );
    await tester.tap(find.text('Choose a date to see prices'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.tap(find.byTooltip('Close date and time'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.tap(find.byTooltip('Close date and time'));
    await tester.pumpAndSettle();
    expect(tester.widget<InputDecorator>(dateField).isEmpty, isTrue);
    final selected = DateTime.now().add(const Duration(days: 2));
    container
        .read(bookingFlowProvider.notifier)
        .updateJourney(
          (j) => j.copyWith(
            pickupDate: DateUtils.dateOnly(selected),
            pickupTime: const TimeOfDay(hour: 15, minute: 5),
          ),
        );
    await tester.pumpAndSettle();
    expect(tester.widget<InputDecorator>(dateField).isEmpty, isFalse);
    // A date makes it quotable, and the button is now the way on.
    expect(find.text('See prices'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
      isTrue,
    );

    // Edit goes back to the route, with everything kept.
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Plan your journey'), findsOneWidget);
    for (final label in ['Pickup address', 'Destination']) {
      expect(tester.widget<InputDecorator>(fieldNamed(label)).isEmpty, isFalse);
    }
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<InputDecorator>(fieldNamed('Pickup date & time')).isEmpty,
      isFalse,
    );
    expect(find.text('PICKUP DATE & TIME'), findsOneWidget);
    expect(
      find.text(
        Formatting.journeyDateAndTime(
          DateTime(selected.year, selected.month, selected.day, 15, 5),
        ),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('swapping a route reverses stops and invalidates its price', (
    tester,
  ) async {
    final repository = FakeBookingRepository()
      ..nextQuote = quoteExpiringIn(const Duration(minutes: 20));
    final container = ProviderContainer(
      overrides: [bookingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final stops = [
      const PlaceSelection(address: 'Stop A'),
      const PlaceSelection(address: 'Stop B'),
    ];
    container
        .read(bookingFlowProvider.notifier)
        .updateJourney((_) => quotableJourney.copyWith(via: stops));
    await container.read(bookingFlowProvider.notifier).requestQuote();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const JourneyScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Swap pickup and destination'));
    await tester.pumpAndSettle();
    final state = container.read(bookingFlowProvider);
    expect(state.journey.pickup, quotableJourney.dropoff);
    expect(state.journey.dropoff, quotableJourney.pickup);
    expect(state.journey.via, stops.reversed.toList());
    expect(state.journey.pickupDate, quotableJourney.pickupDate);
    expect(state.quote, isNull);
  });
  testWidgets('add a stop chooses an address directly and can remove it', (
    tester,
  ) async {
    phoneSized(tester);
    final container = ProviderContainer(
      overrides: [
        bookingRepositoryProvider.overrideWithValue(FakeBookingRepository()),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const JourneyScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Plan your journey'), findsOneWidget);
    expect(find.text('Plan a journey'), findsNothing);
    expect(find.textContaining('Tell us where and when'), findsNothing);
    await tester.ensureVisible(find.text('Add a stop'));
    await tester.tap(find.text('Add a stop'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    addTearDown(tester.view.resetViewInsets);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Southampton Airport'));
    await tester.tap(find.text('Southampton Airport'));
    await tester.pumpAndSettle();
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(tester.takeException(), isNull);
    expect(
      container.read(bookingFlowProvider).journey.via.single.address,
      'Southampton Airport',
    );
    await tester.tap(find.byTooltip('Remove Stop 1'));
    await tester.pumpAndSettle();
    expect(container.read(bookingFlowProvider).journey.via, isEmpty);
    expect(find.text('Continue'), findsOneWidget);
  });
  testWidgets(
    'pickup and destination use sheets and closing preserves the form',
    (tester) async {
      phoneSized(tester);
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(FakeBookingRepository()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const JourneyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(fieldNamed('Pickup address'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      await tester.tap(find.byTooltip('Close address search'));
      await tester.pumpAndSettle();
      expect(
        container.read(bookingFlowProvider).journey.pickup.isEmpty,
        isTrue,
      );
      await tester.tap(fieldNamed('Pickup address'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Southampton Airport'));
      await tester.tap(find.text('Southampton Airport'));
      await tester.pumpAndSettle();
      await tester.tap(fieldNamed('Destination'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      await tester.tap(find.text('Heathrow Airport'));
      await tester.pumpAndSettle();
      final journey = container.read(bookingFlowProvider).journey;
      expect(journey.pickup.address, 'Southampton Airport');
      expect(journey.dropoff.address, 'Heathrow Airport');
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the launch location prefills an empty pickup and only that', (
    tester,
  ) async {
    const here = PlaceSelection(
      address: '14 Bedford Pl, Southampton',
      placeId: 'here',
      latitude: 50.91,
      longitude: -1.4,
    );
    Future<ProviderContainer> pump(PlaceSelection pickup) async {
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(FakeBookingRepository()),
          currentPlaceProvider.overrideWith((ref) async => here),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(bookingFlowProvider.notifier)
          .updateJourney((j) => j.copyWith(pickup: pickup));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            key: UniqueKey(),
            theme: AppTheme.light(),
            home: const JourneyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    phoneSized(tester);
    var c = await pump(PlaceSelection.empty);
    expect(c.read(bookingFlowProvider).journey.pickup, here);

    c = await pump(quotableJourney.pickup);
    expect(c.read(bookingFlowProvider).journey.pickup, quotableJourney.pickup);
  });
}
