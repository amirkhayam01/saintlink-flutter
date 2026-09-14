import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saints_link/src/core/api_client.dart';
import 'package:saints_link/src/core/api_exception.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/features/booking/booking_flow_controller.dart';
import 'package:saints_link/src/features/booking/journey_screen.dart';
import 'package:saints_link/src/features/home/home_screen.dart';
import 'package:saints_link/src/features/places/place_autocomplete_field.dart';
import 'package:saints_link/src/features/places/places_repository.dart';

import '../support/fakes.dart';

class PlacesApi implements ApiClient {
  final queries = <String>[];
  final delayed = <String, Completer<Map<String, dynamic>>>{};
  bool failDetails = false;
  String? suggestionDescription;
  String? resolvedId;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    if (path == '/places/autocomplete') {
      final text = query!['query'] as String;
      queries.add(text);
      if (delayed.containsKey(text)) return delayed[text]!.future;
      return suggestionDescription == null
          ? suggestions(text)
          : {
              'data': [
                {
                  'place_id': 'google-$text',
                  'description': suggestionDescription,
                },
              ],
            };
    }
    resolvedId = query!['place_id'] as String;
    if (failDetails) {
      throw const ApiException('Address lookup is temporarily unavailable.');
    }
    return {
      'place_id': resolvedId,
      'address': 'Hounslow, UK',
      'latitude': 51.47,
      'longitude': -0.45,
    };
  }

  static Map<String, dynamic> suggestions(String text) => {
    'data': [
      {'place_id': 'google-$text', 'description': '$text, UK'},
    ],
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'selecting a Google destination opens booking with its coordinates',
    (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      const airport = 'Heathrow Airport London (LHR), Hounslow';
      final api = PlacesApi()..suggestionDescription = airport;
      final container = ProviderContainer(
        overrides: [
          placesRepositoryProvider.overrideWithValue(PlacesRepository(api)),
          bookingRepositoryProvider.overrideWithValue(
            FakeBookingRepository()..vehicles = fixtureVehicles(),
          ),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/book', builder: (_, _) => const JourneyScreen()),
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
      container
          .read(bookingFlowProvider.notifier)
          .updateJourney((_) => quotableJourney);
      expect(find.text('Book'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Heathrow');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(airport));
      await tester.tap(find.text(airport));
      await tester.pumpAndSettle();
      expect(find.text('Plan your journey'), findsOneWidget);
      final journey = container.read(bookingFlowProvider).journey;
      expect(api.resolvedId, 'google-Heathrow');
      expect(journey.dropoff.placeId, 'google-Heathrow');
      expect(journey.dropoff.isLocated, isTrue);
      expect(journey.dropoff.address, airport);
      expect(journey.dropoff.latitude, 51.47);
      expect(journey.dropoff.longitude, -0.45);
      expect(journey.touchesAirport, isTrue);
      expect(find.text(airport), findsOneWidget);
      expect(journey.pickup.isEmpty, isTrue);
      expect(journey.pickupDate, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'old responses and cleared queries cannot restore stale suggestions',
    (tester) async {
      final api = PlacesApi();
      api.delayed['South'] = Completer<Map<String, dynamic>>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            placesRepositoryProvider.overrideWithValue(PlacesRepository(api)),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(body: PlaceAutocompleteField(onSelected: (_) {})),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'South');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.enterText(find.byType(TextField), 'Heathrow');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      api.delayed['South']!.complete(PlacesApi.suggestions('South'));
      await tester.pumpAndSettle();
      expect(find.text('Heathrow, UK'), findsOneWidget);
      expect(find.text('South, UK'), findsNothing);
      await tester.tap(find.byTooltip('Clear destination'));
      await tester.pumpAndSettle();
      expect(find.text('Heathrow, UK'), findsNothing);
      expect(api.queries, ['South', 'Heathrow']);
    },
  );

  testWidgets(
    'a failed place lookup stays in search and allows another selection',
    (tester) async {
      final api = PlacesApi()..failDetails = true;
      var selections = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            placesRepositoryProvider.overrideWithValue(PlacesRepository(api)),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: PlaceAutocompleteField(onSelected: (_) => selections++),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Heathrow');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Heathrow, UK'));
      await tester.pumpAndSettle();
      expect(selections, 0);
      expect(
        find.text('Address lookup is temporarily unavailable.'),
        findsOneWidget,
      );
      api.failDetails = false;
      await tester.tap(find.text('Heathrow, UK'));
      await tester.pumpAndSettle();
      expect(selections, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
