import 'package:freezed_annotation/freezed_annotation.dart';

import 'json.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

/// The signed-in customer, as `AuthController::presentCustomer` sends it.
@freezed
abstract class Customer with _$Customer {
  const factory Customer({
    required int id,
    required String name,
    required String firstName,
    String? lastName,
    String? email,
    required String phone,
    required String maskedPhone,
    required bool marketingConsent,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}

/// The outcome of asking for a sign-in code.
@freezed
abstract class SignInCodeRequest with _$SignInCodeRequest {
  const factory SignInCodeRequest({
    required String maskedPhone,
    @JsonKey(fromJson: localDateTime) required DateTime expiresAt,
    required int resendAfterSeconds,
  }) = _SignInCodeRequest;

  factory SignInCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInCodeRequestFromJson(json);
}
