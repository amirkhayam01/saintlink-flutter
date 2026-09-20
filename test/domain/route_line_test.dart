import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/domain/route_line.dart';

void main() {
  test('decodes the polyline example from the Google docs', () {
    expect(decodePolyline(r'_p~iF~ps|U_ulLnnqC_mqNvxq`@'), [
      (38.5, -120.2),
      (40.7, -120.95),
      (43.252, -126.453),
    ]);
  });

  test('a route parses its totals', () {
    final route = RouteLine.fromJson({
      'polyline': r'_p~iF~ps|U',
      'distance_meters': 120000,
      'duration_seconds': 6000,
    });
    expect(route.points, [(38.5, -120.2)]);
    expect(route.distanceMeters, 120000);
    expect(route.durationSeconds, 6000);
  });
}
