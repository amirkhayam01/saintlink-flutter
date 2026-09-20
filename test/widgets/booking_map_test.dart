import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/domain/place.dart';
import 'package:saints_link/src/features/booking/booking_screen_header.dart';
import 'package:saints_link/src/features/booking/google_journey_map.dart';
import 'package:saints_link/src/features/places/current_location.dart';
import 'package:saints_link/src/widgets/route_timeline.dart';

import '../support/fakes.dart';
import '../support/platform_views.dart';

/// The map reads whether location is already granted; no test here wants a
/// real permission check, so each says so up front.
Widget scoped(Widget app, {bool granted = false}) => ProviderScope(
  overrides: [locationGrantedProvider.overrideWith((ref) async => granted)],
  child: app,
);

void main() {
  setUp(stubPlatformViews);

  // Pins for located places in travel order; none for a typed address.
  testWidgets('pins located places in travel order and skips typed ones', (
    tester,
  ) async {
    final journey = quotableJourney.copyWith(
      via: const [
        PlaceSelection(
          address: 'Winchester',
          latitude: 51.06,
          longitude: -1.31,
        ),
        PlaceSelection(address: 'somewhere typed, never picked'),
      ],
      dropoff: const PlaceSelection(
        address: 'Heathrow Airport',
        latitude: 51.47,
        longitude: -0.45,
      ),
    );
    // The pins are drawn through the engine, which only runs for real time.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        scoped(
          MaterialApp(
            theme: AppTheme.light(),
            home: SizedBox.expand(
              child: GoogleJourneyMap(journey: journey, topPadding: 86),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(map.markers.map((m) => m.markerId.value), ['A', '1', 'B']);
    // Drawn, not Google's default pins, and centred on the point.
    expect(map.markers.every((m) => m.anchor == const Offset(0.5, 0.5)), isTrue);
    expect(map.markers.map((m) => m.infoWindow.title), [
      journey.pickup.address,
      'Winchester',
      'Heathrow Airport',
    ]);
    // The header's route card floats over the top; the framing stays clear of it.
    expect(map.padding, const EdgeInsets.only(top: 86));
    // A preview, not a map to explore.
    expect(map.scrollGesturesEnabled, isFalse);
    expect(map.liteModeEnabled, isTrue);
    // Nothing granted, so no dot — and, more to the point, no prompt.
    expect(map.myLocationEnabled, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('with nothing located there is a nudge, not an empty map', (
    tester,
  ) async {
    await tester.pumpWidget(
      scoped(
        MaterialApp(
          theme: AppTheme.light(),
          home: SizedBox.expand(
            child: GoogleJourneyMap(
              journey: quotableJourney.copyWith(
                pickup: const PlaceSelection(address: 'typed'),
                dropoff: const PlaceSelection(address: 'also typed'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(GoogleMap), findsNothing);
    expect(find.textContaining('Choose your addresses'), findsOneWidget);
  });

  testWidgets('the expanded sheet is the interactive one, in a dark style', (
    tester,
  ) async {
    await tester.pumpWidget(
      scoped(
        MaterialApp(
          theme: AppTheme.dark(),
          home: SizedBox.expand(
            child: GoogleJourneyMap(
              journey: quotableJourney,
              interactive: true,
            ),
          ),
        ),
        granted: true,
      ),
    );
    await tester.pumpAndSettle();

    final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(map.scrollGesturesEnabled, isTrue);
    expect(map.liteModeEnabled, isFalse);
    expect(map.style, isNotNull);
    // Granted already, so the "you are here" dot draws — and the button to
    // recentre on it, since this is the map you can move.
    expect(map.myLocationEnabled, isTrue);
    expect(map.myLocationButtonEnabled, isTrue);
  });

  for (final dark in [false, true]) {
    testWidgets('map header and expansion fit narrow large text: $dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final journey = quotableJourney.copyWith(
        dropoff: const PlaceSelection(
          address: 'Heathrow Airport London (LHR), Hounslow',
          latitude: 51.47,
          longitude: -.45,
        ),
      );
      await tester.pumpWidget(
        scoped(
          MaterialApp(
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: Scaffold(
              appBar: BookingScreenHeader(
                title: 'Choose your vehicle',
                journey: journey,
                expandable: true,
              ),
              body: const Text('Form'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // The route card over the map is the shared timeline, not its own thing.
      expect(find.byType(RouteTimeline), findsOneWidget);
      expect(find.text(journey.pickup.address), findsOneWidget);
      expect(find.text(journey.dropoff.address), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Expand map'));
      await tester.pumpAndSettle();
      expect(find.text('Journey map'), findsOneWidget);
      expect(find.byType(GoogleJourneyMap), findsNWidgets(2));
      expect(
        tester
            .widgetList<GoogleJourneyMap>(find.byType(GoogleJourneyMap))
            .where((map) => map.interactive),
        hasLength(1),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Close map'));
      await tester.pumpAndSettle();
      expect(find.text('Journey map'), findsNothing);
    });
  }
}
