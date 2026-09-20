import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/place.dart';
import '../../domain/route_line.dart';

/// The road route through these points, fetched once per set and kept for the
/// session. Null when the server has no route; the map then shows pins alone.
///
/// Keyed by [routeKey] rather than the list itself, which has no value
/// equality and would refetch on every rebuild.
final routeLineProvider = FutureProvider.family<RouteLine?, String>((
  ref,
  key,
) async {
  ref.keepAlive();
  try {
    final route = await ref
        .watch(placesRepositoryProvider)
        .route(key.split('|'));
    if (kDebugMode) {
      debugPrint(
        'route line for $key: ${route.points.length} points, '
        '${route.distanceMeters} m',
      );
    }
    return route;
  } catch (error, stack) {
    // Pins alone is a fine fallback, but the reason must not vanish.
    await ref
        .read(errorReporterProvider)
        .report(error, stack, context: 'route line for $key');
    return null;
  }
});

/// `lat,lng|lat,lng|…` for the located points, pickup first.
String routeKey(Iterable<PlaceSelection> points) =>
    points.map((p) => '${p.latitude},${p.longitude}').join('|');
