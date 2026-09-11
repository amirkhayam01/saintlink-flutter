import 'package:freezed_annotation/freezed_annotation.dart';

part 'place.freezed.dart';
part 'place.g.dart';

/// A suggestion from `/places/autocomplete`.
@freezed
abstract class PlaceSuggestion with _$PlaceSuggestion {
  const factory PlaceSuggestion({
    required String placeId,
    required String description,
  }) = _PlaceSuggestion;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) => _$PlaceSuggestionFromJson(json);
}

/// One end of a journey, as the customer chose it.
///
/// Built from `/places/details` when a suggestion is picked, or from typed
/// text alone when it is not.
@freezed
abstract class PlaceSelection with _$PlaceSelection {
  const PlaceSelection._();

  const factory PlaceSelection({
    required String address,
    String? placeId,
    double? latitude,
    double? longitude,
  }) = _PlaceSelection;

  factory PlaceSelection.fromJson(Map<String, dynamic> json) => _$PlaceSelectionFromJson(json);

  static const empty = PlaceSelection(address: '');

  bool get isEmpty => address.trim().isEmpty;

  /// Whether the pricing engine can measure from this rather than guess.
  ///
  /// An address typed by hand and never picked from the suggestions has no
  /// coordinates. It can still be priced — the server falls back to matching
  /// the text against its own known locations — but far less precisely, so the
  /// form nudges the customer to choose a suggestion.
  bool get isLocated => latitude != null && longitude != null;
}
