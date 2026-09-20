import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/core/formatting.dart';
import 'package:saints_link/src/domain/place.dart';
import 'package:saints_link/src/features/booking/booking_flow_controller.dart';
import 'package:saints_link/src/features/booking/journey_screen.dart';

import '../support/fakes.dart';

/// The field a caption names. Captions sit above their fields now, so the
/// tappable control carries the caption as its semantics label — which is
/// also what a screen reader announces for it.
Finder fieldNamed(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == label,
  ),
  matching: find.byType(InputDecorator),
);

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

  testWidgets(
    'booking fields use floating labels without repeated section headings',
    (tester) async {
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
      expect(find.text('Passengers & luggage'), findsNothing);
      expect(find.text('PICKUP DATE & TIME'), findsOneWidget);
      final dateField = fieldNamed('Pickup date & time');
      for (final label in ['Pickup address', 'Destination']) {
        final field = fieldNamed(label);
        expect(tester.widget<InputDecorator>(field).isEmpty, isTrue);
        expect(find.text(label.toUpperCase()), findsOneWidget);
      }
      expect(tester.widget<InputDecorator>(dateField).isEmpty, isTrue);
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
              pickup: quotableJourney.pickup,
              dropoff: quotableJourney.dropoff,
              pickupDate: DateUtils.dateOnly(selected),
              pickupTime: const TimeOfDay(hour: 15, minute: 5),
            ),
          );
      await tester.pumpAndSettle();
      for (final label in ['Pickup address', 'Destination']) {
        final field = fieldNamed(label);
        expect(tester.widget<InputDecorator>(field).isEmpty, isFalse);
        expect(find.text(label.toUpperCase()), findsOneWidget);
      }
      expect(tester.widget<InputDecorator>(dateField).isEmpty, isFalse);
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
    },
  );

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
      await tester.tap(
        fieldNamed('Pickup address'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      await tester.tap(find.byTooltip('Close address search'));
      await tester.pumpAndSettle();
      expect(
        container.read(bookingFlowProvider).journey.pickup.isEmpty,
        isTrue,
      );
      await tester.tap(
        fieldNamed('Pickup address'),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Southampton Airport'));
      await tester.tap(find.text('Southampton Airport'));
      await tester.pumpAndSettle();
      await tester.tap(
        fieldNamed('Destination'),
      );
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
}
