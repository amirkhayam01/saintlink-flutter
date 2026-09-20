import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:saints_link/src/core/api_client.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/domain/place.dart';
import 'package:saints_link/src/features/booking/google_journey_map.dart';
import 'package:saints_link/src/features/places/current_location.dart';
import 'package:saints_link/src/features/places/places_repository.dart';

import '../support/fakes.dart';
import '../support/platform_views.dart';

// The whole route pipeline, app side: the request the map makes, the
// server's answer decoded, and the line handed to the map.
class RouteApi implements ApiClient {
  Map<String, dynamic>? lastQuery;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    expect(path, '/places/route');
    lastQuery = query;
    return {
      'polyline': r'_p~iF~ps|U_ulLnnqC_mqNvxq`@',
      'distance_meters': 120000,
      'duration_seconds': 6000,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(stubPlatformViews);

  testWidgets('a located route asks the server for its line and draws it', (
    tester,
  ) async {
    final api = RouteApi();
    final journey = quotableJourney.copyWith(
      dropoff: const PlaceSelection(
        address: 'Heathrow Airport',
        latitude: 51.47,
        longitude: -0.45,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placesRepositoryProvider.overrideWithValue(PlacesRepository(api)),
          locationGrantedProvider.overrideWith((ref) async => false),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: SizedBox.expand(child: GoogleJourneyMap(journey: journey)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.lastQuery, {
      'points[]': [
        '${journey.pickup.latitude},${journey.pickup.longitude}',
        '51.47,-0.45',
      ],
    });
    final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(map.polylines, hasLength(1));
    expect(map.polylines.single.points, hasLength(3));
  });
}
