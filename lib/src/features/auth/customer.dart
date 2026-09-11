import 'package:flutter/foundation.dart';

/// The signed-in customer.
///
/// There is no password anywhere in this model: identity is a verified phone
/// number, and the token in secure storage is the only credential.
@immutable
class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.firstName,
    required this.phone,
    required this.maskedPhone,
    required this.marketingConsent,
    this.lastName,
    this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as int,
        name: json['name'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String,
        maskedPhone: json['masked_phone'] as String,
        marketingConsent: json['marketing_consent'] as bool,
      );

  final int id;
  final String name;
  final String firstName;
  final String? lastName;
  final String? email;
  final String phone;
  final String maskedPhone;
  final bool marketingConsent;
}

/// The outcome of asking for a sign-in code.
@immutable
class SignInCodeRequest {
  const SignInCodeRequest({
    required this.maskedPhone,
    required this.expiresAt,
    required this.resendAfterSeconds,
  });

  factory SignInCodeRequest.fromJson(Map<String, dynamic> json) => SignInCodeRequest(
        maskedPhone: json['masked_phone'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String).toLocal(),
        resendAfterSeconds: json['resend_after_seconds'] as int,
      );

  final String maskedPhone;
  final DateTime expiresAt;
  final int resendAfterSeconds;
}
