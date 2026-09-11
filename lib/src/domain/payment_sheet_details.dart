import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_sheet_details.freezed.dart';
part 'payment_sheet_details.g.dart';

/// What the native payment sheet needs to take a card, from
/// `POST /bookings/{reference}/payment-intent`.
@freezed
abstract class PaymentSheetDetails with _$PaymentSheetDetails {
  const factory PaymentSheetDetails({
    required String clientSecret,
    required String publishableKey,
    required String merchantName,
    required double amount,
    required String currency,
  }) = _PaymentSheetDetails;

  factory PaymentSheetDetails.fromJson(Map<String, dynamic> json) => _$PaymentSheetDetailsFromJson(json);
}
