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
}
