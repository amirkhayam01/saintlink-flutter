import '../../core/api_client.dart';
import '../../domain/place.dart';

/// Address search, proxied through Saints Link.
///
/// The app never holds a Google key: the server keeps it, which is what allows
/// it to be restricted and what keeps the billed calls throttleable.
class PlacesRepository {
  PlacesRepository(this._api);

  final ApiClient _api;

  Future<List<PlaceSuggestion>> search(String query) async {
    if (query.trim().length < 3) return const [];

    final response = await _api.get(
      '/places/autocomplete',
      query: {'query': query.trim()},
    );

    return (response['data'] as List<dynamic>)
        .map((item) => PlaceSuggestion.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Only continue after the server has verified the selected Google place.
  Future<PlaceSelection> resolve(PlaceSuggestion suggestion) async {
    final response = await _api.get(
      '/places/details',
      query: {'place_id': suggestion.placeId},
    );
    final place = PlaceSelection.fromJson(response);
    // Postal addresses can omit the airport or business name the customer
    // selected. Keep that label alongside the verified ID and coordinates.
    final description = suggestion.description.trim();
    return description.isEmpty ? place : place.copyWith(address: description);
  }

  /// The address at a position, as a place the engine will trust.
  ///
  /// A GPS fix is coordinates, and coordinates are neither something the
  /// customer can read back nor somewhere a driver can be sent. The server
  /// turns them into a verified place id and a postal address — the same
  /// thing picking a suggestion produces — so "use my current location"
  /// prices exactly as a typed-and-picked address would.
  Future<PlaceSelection> reverse({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _api.get(
      '/places/reverse',
      query: {'lat': latitude, 'lng': longitude},
    );

    return PlaceSelection.fromJson(response);
  }

  /// The signed-in customer's most-used places, most frequent first.
  ///
  /// Kept by the server from their bookings, so it survives a reinstall and
  /// follows them to a new phone — which the device-side recents cannot.
  Future<List<PlaceSelection>> recent() async {
    final response = await _api.get('/places/recent');

    return (response['data'] as List<dynamic>)
        .map((item) => PlaceSelection.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
