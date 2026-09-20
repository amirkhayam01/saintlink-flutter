import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/domain/quote.dart';
import 'package:saints_link/src/features/booking/booking_flow_controller.dart';
import 'package:saints_link/src/features/booking/journey_screen.dart';

import '../support/fakes.dart';

void main() {
  for (final width in [320.0, 390.0, 768.0]) {
    for (final scale in [1.0, 2.0]) {
      for (final isReturn in [false, true]) {
        testWidgets(
          'vehicle fares fit width $width scale $scale return $isReturn',
          (tester) async {
            tester.view.physicalSize = Size(width, 800);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final fleet = fixtureVehicles()
                .map(
                  (v) => v.copyWith(name: '${v.name} with extra luggage space'),
                )
                .toList();
            final quote = quoteExpiringIn(const Duration(minutes: 4)).copyWith(
              fares: {
                for (final vehicle in fleet)
                  vehicle.slug: const Fare(
                    single: 12345.67,
                    returnTotal: 23456.78,
                  ),
              },
            );
            final container = ProviderContainer(
              overrides: [
                bookingRepositoryProvider.overrideWithValue(
                  FakeBookingRepository()
                    ..vehicles = fleet
                    ..nextQuote = quote,
                ),
              ],
            );
            addTearDown(container.dispose);
            final controller = container.read(bookingFlowProvider.notifier);
            controller.updateJourney(
              (_) => quotableJourney.copyWith(
                isReturn: isReturn,
                returnDate: DateTime(2026, 10, 3),
                returnTime: const TimeOfDay(hour: 10, minute: 0),
              ),
            );
            await controller.requestQuote();
            controller.selectVehicle(fleet.first.slug);
            await tester.pumpWidget(
              UncontrolledProviderScope(
                container: container,
                child: MaterialApp(
                  theme: isReturn ? AppTheme.dark() : AppTheme.light(),
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(scale)),
                    child: child!,
                  ),
                  home: const JourneyScreen(initialStage: JourneyStage.vehicles),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            for (var i = 0; i < fleet.length * 2; i++) {
              await tester.drag(find.byType(ListView), const Offset(0, -220));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
            controller.selectVehicle(fleet.first.slug);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(
              container.read(bookingFlowProvider).totalDue,
              isReturn ? 23456.78 : 12345.67,
            );
            await tester.pumpWidget(const SizedBox.shrink());
          },
        );
      }
    }
  }
  testWidgets('only a vehicle that fits and has a return fare can continue', (
    tester,
  ) async {
    final original = fixtureVehicles();
    final fleet = [
      original[0].copyWith(passengerCapacity: 1, luggageCapacity: 0),
      original[1].copyWith(passengerCapacity: 8, luggageCapacity: 8),
      original[2].copyWith(passengerCapacity: 8, luggageCapacity: 8),
    ];
    final quote = quoteExpiringIn(const Duration(minutes: 20)).copyWith(
      fares: {
        fleet[0].slug: const Fare(single: 100, returnTotal: 200),
        fleet[1].slug: const Fare(single: 150, returnTotal: 300),
        fleet[2].slug: const Fare(single: 120),
      },
    );
    final container = ProviderContainer(
      overrides: [
        bookingRepositoryProvider.overrideWithValue(
          FakeBookingRepository()
            ..vehicles = fleet
            ..nextQuote = quote,
        ),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(bookingFlowProvider.notifier);
    controller.updateJourney(
      (_) => quotableJourney.copyWith(
        isReturn: true,
        returnDate: DateTime(2026, 10, 3),
        returnTime: const TimeOfDay(hour: 10, minute: 0),
      ),
    );
    await controller.requestQuote();
    controller.selectVehicle(fleet[0].slug);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const JourneyScreen(initialStage: JourneyStage.vehicles),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.scrollUntilVisible(
      find.text(fleet[2].name),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(fleet[2].name));
    await tester.pumpAndSettle();
    expect(
      container.read(bookingFlowProvider).journey.vehicleCategorySlug,
      fleet[0].slug,
    );
    expect(find.text('Unavailable for this return journey'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(fleet[1].name),
      -180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(fleet[1].name));
    await tester.pumpAndSettle();
    expect(
      container.read(bookingFlowProvider).journey.vehicleCategorySlug,
      fleet[1].slug,
    );
    expect(container.read(bookingFlowProvider).totalDue, 300);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('expired fare fits a short screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        bookingRepositoryProvider.overrideWithValue(
          FakeBookingRepository()
            ..vehicles = fixtureVehicles()
            ..nextQuote = quoteExpiringIn(const Duration(seconds: -1)),
        ),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(bookingFlowProvider.notifier);
    controller.updateJourney((_) => quotableJourney);
    await controller.requestQuote();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dark(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const JourneyScreen(initialStage: JourneyStage.vehicles),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Refresh price'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
