/// A road route as the map draws it: the decoded polyline and the totals.
class RouteLine {
  const RouteLine({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  factory RouteLine.fromJson(Map<String, dynamic> json) => RouteLine(
    points: decodePolyline(json['polyline'] as String),
    distanceMeters: (json['distance_meters'] as num).toInt(),
    durationSeconds: (json['duration_seconds'] as num).toInt(),
  );

  /// Latitude/longitude pairs.
  final List<(double, double)> points;
  final int distanceMeters;
  final int durationSeconds;
}

/// Google's encoded polyline format.
List<(double, double)> decodePolyline(String encoded) {
  final points = <(double, double)>[];
  var index = 0;
  var lat = 0;
  var lng = 0;

  int next() {
    var result = 0;
    var shift = 0;
    int byte;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    return (result & 1) != 0 ? ~(result >> 1) : result >> 1;
  }

  while (index < encoded.length) {
    lat += next();
    lng += next();
    points.add((lat / 1e5, lng / 1e5));
  }

  return points;
}
