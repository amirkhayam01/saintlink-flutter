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
    return await ref.watch(placesRepositoryProvider).route(key.split('|'));
  } catch (_) {
    return null;
  }
});

/// `lat,lng|lat,lng|…` for the located points, pickup first.
String routeKey(Iterable<PlaceSelection> points) =>
    points.map((p) => '${p.latitude},${p.longitude}').join('|');
