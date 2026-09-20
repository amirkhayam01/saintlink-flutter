import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/features/booking/booking_flow_controller.dart';
import 'package:saints_link/src/features/booking/journey_screen.dart';

import '../support/fakes.dart';

Finder field(String hint) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == hint,
);

void main() {
  testWidgets(
    'flight details retain quote and are submitted with the booking',
    (tester) async {
      final repository = FakeBookingRepository()
        ..vehicles = fixtureVehicles()
        ..nextQuote = quoteExpiringIn(const Duration(minutes: 20))
        ..nextBooking = bookingWith(reference: 'SL-FLIGHT');
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(repository),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(bookingFlowProvider.notifier);
      controller.updateJourney((_) => quotableJourney);
      await controller.requestQuote();
      controller.selectVehicle('saloon-car');
      final quote = container.read(bookingFlowProvider).quote;
      final router = GoRouter(
        initialLocation: '/book/details',
        routes: [
          GoRoute(
            path: '/book/details',
            builder: (_, _) => const JourneyScreen(initialStage: JourneyStage.details),
          ),
          GoRoute(
            path: '/book/confirmed',
            builder: (_, _) => const Scaffold(body: Text('Booked')),
          ),
        ],
      );
      addTearDown(router.dispose);
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
      await tester.enterText(field('e.g. Ada Lovelace'), 'Ada Lovelace');
      await tester.scrollUntilVisible(
        field('07700 900123'),
        150,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(field('07700 900123'), '07700900123');
      await tester.scrollUntilVisible(
        field('e.g. BA123'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(field('e.g. BA123'), 'ba123');
      await tester.scrollUntilVisible(
        field('e.g. T5'),
        100,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(field('e.g. T5'), 'T5');
      await tester.pumpAndSettle();
      expect(container.read(bookingFlowProvider).quote, quote);
      expect(
        container.read(bookingFlowProvider).journey.vehicleCategorySlug,
        'saloon-car',
      );
      await tester.tap(find.textContaining('Confirm booking'));
      await tester.pumpAndSettle();
      expect(find.text('Booked'), findsOneWidget);
      expect(
        repository.bookingRequests.single['outbound_flight_number'],
        'BA123',
      );
      expect(repository.bookingRequests.single['outbound_terminal'], 'T5');
      expect(repository.bookingRequests.single['quote_token'], quote!.token);
      expect(tester.takeException(), isNull);
    },
  );

  for (final dark in [false, true]) {
    testWidgets('Details fits narrow large text with flight fields: $dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
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
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: const JourneyScreen(initialStage: JourneyStage.details),
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
    });
  }
}
