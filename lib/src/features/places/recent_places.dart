import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import '../../domain/place.dart';
import '../auth/auth_controller.dart';
import '../auth/demo_session.dart';

/// The last few places the customer chose, kept on the device.
///
/// A convenience, not data: it lives in plain preferences, is capped short,
/// and losing it costs nothing but a few taps. Located places only — a typed
/// address with no coordinates is not worth offering again.
class RecentPlaces extends AsyncNotifier<List<PlaceSelection>> {
  static const _key = 'saints_link.recent_places';
  static const _limit = 5;

  @override
  Future<List<PlaceSelection>> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? const [];

      return raw.map((item) => PlaceSelection.fromJson(jsonDecode(item) as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> remember(PlaceSelection place) async {
    if (!place.isLocated) return;

    final current = state.value ?? const [];
    final next = [place, ...current.where((p) => p.placeId != place.placeId && p.address != place.address)].take(_limit).toList();
    state = AsyncData(next);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, next.map((p) => jsonEncode(p.toJson())).toList());
    } catch (_) {
      // Kept for this session only; nothing to recover from.
    }
  }
}

final recentPlacesProvider = AsyncNotifierProvider<RecentPlaces, List<PlaceSelection>>(RecentPlaces.new);

/// The places the server has seen this customer book, most used first.
///
/// Empty for a guest without a request being made, and refetched whenever the
/// customer signs in or out because it watches the session. A booking
/// invalidates it, so the list moves the moment a journey is confirmed.
final customerPlacesProvider = FutureProvider<List<PlaceSelection>>((ref) async {
  if (!ref.watch(authControllerProvider.select((auth) => auth.isSignedIn))) {
    return const [];
  }

  // A preview session is signed in without a server behind it.
  if (ref.watch(demoSessionProvider) != null) return const [];

  try {
    return await ref.watch(placesRepositoryProvider).recent();
  } catch (_) {
    // The device list below still stands; a failed sync costs nothing visible.
    return const [];
  }
});

/// What "Go again" shows: the server's list where there is one, then anything
/// the device remembers that the server has not seen.
///
/// The server ranks by how often a place was booked, which is the order that
/// serves habit, so it goes first. The device list fills in behind it for a
/// guest, for a customer whose sync failed, and for the moments between
/// choosing a place and the booking that would teach the server about it.
final goAgainPlacesProvider = Provider<List<PlaceSelection>>((ref) {
  final synced = ref.watch(customerPlacesProvider).value ?? const <PlaceSelection>[];
  final local = ref.watch(recentPlacesProvider).value ?? const <PlaceSelection>[];

  bool same(PlaceSelection a, PlaceSelection b) =>
      (a.placeId != null && a.placeId == b.placeId) || a.address == b.address;

  return [
    ...synced,
    ...local.where((place) => !synced.any((s) => same(s, place))),
  ];
});

/// Places the fleet serves so often they deserve one tap.
///
/// Names and coordinates are the server's own (`TaxiOperationsSeeder`), so a
/// shortcut prices exactly like the same place picked from a suggestion.
const shortcutPlaces = <PlaceSelection>[
  PlaceSelection(address: 'Heathrow Airport', latitude: 51.4700, longitude: -0.4543),
  PlaceSelection(address: 'Gatwick Airport', latitude: 51.1537, longitude: -0.1821),
  PlaceSelection(address: 'Southampton Cruise Terminals', latitude: 50.8994, longitude: -1.4114),
  PlaceSelection(address: 'Southampton Airport', latitude: 50.9503, longitude: -1.3568),
  PlaceSelection(address: 'Bournemouth Airport', latitude: 50.7800, longitude: -1.8425),
  PlaceSelection(address: 'London Stansted Airport', latitude: 51.8850, longitude: 0.2350),
];
