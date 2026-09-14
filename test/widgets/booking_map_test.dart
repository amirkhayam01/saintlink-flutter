import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/domain/place.dart';
import 'package:saints_link/src/features/booking/booking_screen_header.dart';
import 'package:saints_link/src/features/booking/google_journey_map.dart';

import '../support/fakes.dart';

class MissingMapBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) => key.endsWith('southern_england.png')
      ? Future.error(FlutterError('Unable to load asset: $key'))
      : rootBundle.load(key);
}

void main() {
  testWidgets('missing map image keeps the header usable', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: DefaultAssetBundle(
          bundle: MissingMapBundle(),
          child: Scaffold(
            appBar: BookingScreenHeader(
              title: 'Plan your journey',
              journey: quotableJourney,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Plan your journey'), findsOneWidget);
    expect(find.byType(ErrorWidget), findsNothing);
  });

  test(
    'route preserves exact places, ordered stops and safely encoded text',
    () {
      final journey = quotableJourney.copyWith(
        via: const [
          PlaceSelection(address: 'Via', latitude: 51.1, longitude: -1),
        ],
        dropoff: const PlaceSelection(
          address: '</script><script>alert(1)</script>',
        ),
      );
      final html = journeyMapHtml(
        journey,
        key: 'test-key',
        interactive: true,
        topPadding: 86,
      );
      final config = jsonDecode(
        RegExp(r'const config=(.*);').firstMatch(html)!.group(1)!,
      ) as Map<String, dynamic>;
      expect(config['stops'], [
        {'placeId': 'p1'},
        {'lat': 51.1, 'lng': -1.0},
        journey.dropoff.address,
      ]);
      expect(html, isNot(contains(journey.dropoff.address)));
      expect(config['topPadding'], 86);
    },
  );

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
        MaterialApp(
          theme: dark ? AppTheme.dark() : AppTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
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
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.trip_origin_rounded), findsOneWidget);
      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
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
