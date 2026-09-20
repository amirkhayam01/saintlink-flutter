import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/api_client.dart';
import 'package:saints_link/src/core/api_exception.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/domain/place.dart';
import 'package:saints_link/src/features/places/address_search_field.dart';
import 'package:saints_link/src/features/places/current_location.dart';
import 'package:saints_link/src/features/places/places_repository.dart';
import 'package:saints_link/src/features/places/recent_places.dart';

/*
 * "Use my current location" is two steps — the phone gives a fix, the server
 * names it — and each has failures the customer can act on. These pin down
 * that the button is only offered for a pickup, that success returns a place
 * the engine will trust, and that every refusal says something useful and
 * leaves the search usable.
 */

class FakeLocation implements LocationSource {
  FakeLocation({this.fix, this.denial});

  final LocationFix? fix;
  final LocationDenial? denial;
  int settingsOpened = 0;

  @override
  Future<LocationFix> current() async {
    if (denial != null) throw LocationDeniedException(denial!);
    return fix!;
  }

  @override
  Future<bool> isGranted() async => fix != null;

  @override
  Future<void> openSettings() async => settingsOpened++;
}

class ReverseApi implements ApiClient {
  Map<String, dynamic>? lastQuery;
  bool outsideUk = false;

  @override
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    if (path == '/places/recent') return {'data': <dynamic>[]};
    expect(path, '/places/reverse');
    lastQuery = query;
    if (outsideUk) throw const ApiException('We only pick up within the United Kingdom.');
    return {
      'place_id': 'ChIJ-bedford-place',
      'address': '14 Bedford Pl, Southampton SO15 2DB, UK',
      'latitude': 50.9107,
      'longitude': -1.4055,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoRecents extends RecentPlaces {
  @override
  Future<List<PlaceSelection>> build() async => const [];
}

/// Opens the search sheet as the pickup field would, and hands back what it
/// returned once it closes.
Future<PlaceSelection?> Function() pumpSheet(
  WidgetTester tester, {
  required LocationSource location,
  required ApiClient api,
  bool allowCurrentLocation = true,
}) {
  final container = ProviderContainer(overrides: [
    locationSourceProvider.overrideWithValue(location),
    placesRepositoryProvider.overrideWithValue(PlacesRepository(api)),
    recentPlacesProvider.overrideWith(_NoRecents.new),
    customerPlacesProvider.overrideWith((ref) async => const <PlaceSelection>[]),
  ]);
  addTearDown(container.dispose);

  PlaceSelection? result;
  var closed = false;

  return () async {
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      // A fresh key each time: re-pumping the same widget types would update
      // the existing Navigator and leave a previous sheet open underneath.
      child: MaterialApp(
        key: UniqueKey(),
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showAddressSearchSheet(
                    context,
                    title: 'Pickup address',
                    allowCurrentLocation: allowCurrentLocation,
                  );
                  closed = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return closed ? result : null;
  };
}

void main() {
  setUp(() {
    // The sheet sizes itself from the window; a phone-shaped one keeps every
    // row on screen without scrolling.
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
  });

  testWidgets('the button is offered for a pickup and not otherwise', (tester) async {
    final open = pumpSheet(tester, location: FakeLocation(), api: ReverseApi(), allowCurrentLocation: false);
    await open();

    expect(find.text('Use my current location'), findsNothing);
  });

  testWidgets('a fix becomes a verified pickup and closes the sheet', (tester) async {
    final api = ReverseApi();
    final open = pumpSheet(
      tester,
      location: FakeLocation(fix: const LocationFix(latitude: 50.91071, longitude: -1.40549)),
      api: api,
    );
    await open();

    await tester.tap(find.text('Use my current location'));
    await tester.pumpAndSettle();

    // The sheet returned what the server named, as a located place.
    expect(find.text('Use my current location'), findsNothing);
    expect(api.lastQuery, {'lat': 50.91071, 'lng': -1.40549});
  });

  testWidgets('a permanent refusal explains itself and offers settings', (tester) async {
    final location = FakeLocation(denial: LocationDenial.deniedForever);
    final open = pumpSheet(tester, location: location, api: ReverseApi());
    await open();

    await tester.tap(find.text('Use my current location'));
    await tester.pumpAndSettle();

    expect(find.textContaining('turn it on in Settings'), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    expect(location.settingsOpened, 1);
    // The search itself is still there to fall back on.
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('a one-off refusal and a missing fix each say what to do next', (tester) async {
    for (final (denial, expected) in [
      (LocationDenial.denied, 'We need your permission'),
      (LocationDenial.servicesOff, 'switched off on this device'),
      (LocationDenial.unavailable, 'could not find your location'),
    ]) {
      final open = pumpSheet(tester, location: FakeLocation(denial: denial), api: ReverseApi());
      await open();
      await tester.tap(find.text('Use my current location'));
      await tester.pumpAndSettle();

      expect(find.textContaining(expected), findsOneWidget, reason: denial.name);
      expect(find.text('Open settings'), findsNothing, reason: denial.name);
    }
  });

  testWidgets("the server's refusal is shown in its own words", (tester) async {
    final open = pumpSheet(
      tester,
      location: FakeLocation(fix: const LocationFix(latitude: 48.86, longitude: 2.34)),
      api: ReverseApi()..outsideUk = true,
    );
    await open();

    await tester.tap(find.text('Use my current location'));
    await tester.pumpAndSettle();

    expect(find.text('We only pick up within the United Kingdom.'), findsOneWidget);
  });
}
