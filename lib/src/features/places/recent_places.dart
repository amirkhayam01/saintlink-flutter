import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import '../../domain/place.dart';
import '../auth/auth_controller.dart';
import 'recent_places_storage.dart';

/// The last few located places the customer chose, kept on the device.
class RecentPlaces extends AsyncNotifier<List<PlaceSelection>> {
  static const _limit = 5;

  @override
  Future<List<PlaceSelection>> build() async {
    // Never surface one person's saved addresses while this device is signed
    // out, or before a different customer has restored their session.
    if (!ref.watch(authControllerProvider.select((auth) => auth.isSignedIn))) {
      return const [];
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(recentPlacesStorageKey) ?? const [];

      return raw
          .map(
            (item) => PlaceSelection.fromJson(
              jsonDecode(item) as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> remember(PlaceSelection place) async {
    if (!place.isLocated || !ref.read(authControllerProvider).isSignedIn) {
      return;
    }

    final current = state.value ?? const [];
    final next = [
      place,
      ...current.where(
        (p) => p.placeId != place.placeId && p.address != place.address,
      ),
    ].take(_limit).toList();
    state = AsyncData(next);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        recentPlacesStorageKey,
        next.map((p) => jsonEncode(p.toJson())).toList(),
      );
    } catch (_) {
      // Kept for this session only; nothing to recover from.
    }
  }
}

final recentPlacesProvider =
    AsyncNotifierProvider<RecentPlaces, List<PlaceSelection>>(RecentPlaces.new);

/// The server's most-used places for the signed-in customer; empty for a guest.
final customerPlacesProvider = FutureProvider<List<PlaceSelection>>((
  ref,
) async {
  if (!ref.watch(authControllerProvider.select((auth) => auth.isSignedIn))) {
    return const [];
  }

  try {
    return await ref.watch(placesRepositoryProvider).recent();
  } catch (_) {
    // The device list below still stands; a failed sync costs nothing visible.
    return const [];
  }
});

/// What "Recent" shows: the server's list first, then device recents it has not seen.
final goAgainPlacesProvider = Provider<List<PlaceSelection>>((ref) {
  if (!ref.watch(authControllerProvider.select((auth) => auth.isSignedIn))) {
    return const [];
  }
  final synced =
      ref.watch(customerPlacesProvider).value ?? const <PlaceSelection>[];
  final local =
      ref.watch(recentPlacesProvider).value ?? const <PlaceSelection>[];

  bool same(PlaceSelection a, PlaceSelection b) =>
      (a.placeId != null && a.placeId == b.placeId) || a.address == b.address;

  return [
    ...synced,
    ...local.where((place) => !synced.any((s) => same(s, place))),
  ];
});

/// One-tap shortcuts, named and placed as the server's `TaxiOperationsSeeder` has them.
const shortcutPlaces = <PlaceSelection>[
  PlaceSelection(
    address: 'Heathrow Airport',
    latitude: 51.4700,
    longitude: -0.4543,
  ),
  PlaceSelection(
    address: 'Gatwick Airport',
    latitude: 51.1537,
    longitude: -0.1821,
  ),
  PlaceSelection(
    address: 'Southampton Cruise Terminals',
    latitude: 50.8994,
    longitude: -1.4114,
  ),
  PlaceSelection(
    address: 'Southampton Airport',
    latitude: 50.9503,
    longitude: -1.3568,
  ),
  PlaceSelection(
    address: 'Bournemouth Airport',
    latitude: 50.7800,
    longitude: -1.8425,
  ),
  PlaceSelection(
    address: 'London Stansted Airport',
    latitude: 51.8850,
    longitude: 0.2350,
  ),
];
