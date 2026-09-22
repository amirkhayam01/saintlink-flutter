import 'package:shared_preferences/shared_preferences.dart';

const recentPlacesStorageKey = 'saints_link.recent_places';

/// Addresses are personal data on a shared device, so signing out removes the
/// on-device cache as well as the server session.
Future<void> clearStoredRecentPlaces() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(recentPlacesStorageKey);
  } catch (_) {
    // The in-memory state is still cleared by the auth-aware provider.
  }
}
