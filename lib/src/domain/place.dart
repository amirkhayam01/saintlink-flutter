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

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) =>
      _$PlaceSuggestionFromJson(json);
}

/// One end of a journey: a picked suggestion, or typed text alone.
@freezed
abstract class PlaceSelection with _$PlaceSelection {
  const PlaceSelection._();

  const factory PlaceSelection({
    required String address,
    String? placeId,
    double? latitude,
    double? longitude,
  }) = _PlaceSelection;

  factory PlaceSelection.fromJson(Map<String, dynamic> json) =>
      _$PlaceSelectionFromJson(json);

  static const empty = PlaceSelection(address: '');

  bool get isEmpty => address.trim().isEmpty;

  /// Typed-only addresses have no coordinates and are priced by text matching; the form nudges toward a suggestion.
  bool get isLocated => latitude != null && longitude != null;
}
