// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_sheet_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentSheetDetails _$PaymentSheetDetailsFromJson(Map<String, dynamic> json) =>
    _PaymentSheetDetails(
      clientSecret: json['client_secret'] as String,
      publishableKey: json['publishable_key'] as String,
      merchantName: json['merchant_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
    );

Map<String, dynamic> _$PaymentSheetDetailsToJson(
  _PaymentSheetDetails instance,
) => <String, dynamic>{
  'client_secret': instance.clientSecret,
  'publishable_key': instance.publishableKey,
  'merchant_name': instance.merchantName,
  'amount': instance.amount,
  'currency': instance.currency,
};
