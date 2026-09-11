// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Fare _$FareFromJson(Map<String, dynamic> json) => _Fare(
  single: (json['single'] as num).toDouble(),
  returnTotal: (json['return'] as num?)?.toDouble(),
);

Map<String, dynamic> _$FareToJson(_Fare instance) => <String, dynamic>{
  'single': instance.single,
  'return': instance.returnTotal,
};

_Quote _$QuoteFromJson(Map<String, dynamic> json) => _Quote(
  token: json['quote_token'] as String,
  expiresAt: localDateTime(json['expires_at'] as String),
  fares: (json['fares'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, Fare.fromJson(e as Map<String, dynamic>)),
  ),
  distanceMiles: (json['distance_miles'] as num?)?.toDouble(),
  estimatedDurationMinutes: (json['estimated_duration_minutes'] as num?)
      ?.toInt(),
);

Map<String, dynamic> _$QuoteToJson(_Quote instance) => <String, dynamic>{
  'quote_token': instance.token,
  'expires_at': instance.expiresAt.toIso8601String(),
  'fares': instance.fares.map((k, e) => MapEntry(k, e.toJson())),
  'distance_miles': instance.distanceMiles,
  'estimated_duration_minutes': instance.estimatedDurationMinutes,
};
