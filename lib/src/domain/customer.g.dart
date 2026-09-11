// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Customer _$CustomerFromJson(Map<String, dynamic> json) => _Customer(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String,
  maskedPhone: json['masked_phone'] as String,
  marketingConsent: json['marketing_consent'] as bool,
);

Map<String, dynamic> _$CustomerToJson(_Customer instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'phone': instance.phone,
  'masked_phone': instance.maskedPhone,
  'marketing_consent': instance.marketingConsent,
};

_SignInCodeRequest _$SignInCodeRequestFromJson(Map<String, dynamic> json) =>
    _SignInCodeRequest(
      maskedPhone: json['masked_phone'] as String,
      expiresAt: localDateTime(json['expires_at'] as String),
      resendAfterSeconds: (json['resend_after_seconds'] as num).toInt(),
    );

Map<String, dynamic> _$SignInCodeRequestToJson(_SignInCodeRequest instance) =>
    <String, dynamic>{
      'masked_phone': instance.maskedPhone,
      'expires_at': instance.expiresAt.toIso8601String(),
      'resend_after_seconds': instance.resendAfterSeconds,
    };
