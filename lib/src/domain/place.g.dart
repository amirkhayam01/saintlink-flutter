// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaceSuggestion _$PlaceSuggestionFromJson(Map<String, dynamic> json) =>
    _PlaceSuggestion(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$PlaceSuggestionToJson(_PlaceSuggestion instance) =>
    <String, dynamic>{
      'place_id': instance.placeId,
      'description': instance.description,
    };

_PlaceSelection _$PlaceSelectionFromJson(Map<String, dynamic> json) =>
    _PlaceSelection(
      address: json['address'] as String,
      placeId: json['place_id'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PlaceSelectionToJson(_PlaceSelection instance) =>
    <String, dynamic>{
      'address': instance.address,
      'place_id': instance.placeId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
