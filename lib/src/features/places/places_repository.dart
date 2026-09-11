import '../../core/api_client.dart';
import '../booking/journey_draft.dart';
import '../booking/models.dart';

/// Address search, proxied through Saints Link.
///
/// The app never holds a Google key: the server keeps it, which is what allows
/// it to be restricted and what keeps the billed calls throttleable.
class PlacesRepository {
  PlacesRepository(this._api);

  final ApiClient _api;

  Future<List<PlaceSuggestion>> search(String query) async {
    if (query.trim().length < 3) return const [];

    final response = await _api.get('/places/autocomplete', query: {'query': query.trim()});

    return (response['data'] as List<dynamic>)
        .map((item) => PlaceSuggestion.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Resolves a chosen suggestion to coordinates the pricing engine can measure
  /// from. Falls back to the suggestion's own text if the lookup fails, so a
  /// customer is never blocked from continuing — the journey simply prices less
  /// precisely.
  Future<PlaceSelection> resolve(PlaceSuggestion suggestion) async {
    try {
      final response = await _api.get('/places/details', query: {'place_id': suggestion.placeId});

      return PlaceSelection(
        address: response['address'] as String,
        placeId: response['place_id'] as String,
        latitude: (response['latitude'] as num).toDouble(),
        longitude: (response['longitude'] as num).toDouble(),
      );
    } catch (_) {
      return PlaceSelection(address: suggestion.description, placeId: suggestion.placeId);
    }
  }
}
