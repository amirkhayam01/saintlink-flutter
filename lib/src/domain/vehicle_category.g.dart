// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleCategory _$VehicleCategoryFromJson(Map<String, dynamic> json) =>
    _VehicleCategory(
      slug: json['slug'] as String,
      name: json['name'] as String,
      passengerCapacity: (json['passengerCapacity'] as num).toInt(),
      luggageCapacity: (json['luggageCapacity'] as num).toInt(),
      handLuggageCapacity: (json['handLuggageCapacity'] as num).toInt(),
      sortOrder: (json['sortOrder'] as num).toInt(),
      description: json['shortDescription'] as String?,
      capacitySummary: json['capacitySummary'] as String?,
      imagePath: json['image'] as String?,
    );

Map<String, dynamic> _$VehicleCategoryToJson(_VehicleCategory instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'name': instance.name,
      'passengerCapacity': instance.passengerCapacity,
      'luggageCapacity': instance.luggageCapacity,
      'handLuggageCapacity': instance.handLuggageCapacity,
      'sortOrder': instance.sortOrder,
      'shortDescription': instance.description,
      'capacitySummary': instance.capacitySummary,
      'image': instance.imagePath,
    };
