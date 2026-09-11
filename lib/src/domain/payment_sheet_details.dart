import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_sheet_details.freezed.dart';
part 'payment_sheet_details.g.dart';

/// What the native payment sheet needs to take a card, from
/// `POST /bookings/{reference}/payment-intent`.
@freezed
abstract class PaymentSheetDetails with _$PaymentSheetDetails {
  const PaymentSheetDetails._();

  const factory PaymentSheetDetails({
    /// `stripe` for a real card, `fake` while the backend runs
    /// `PAYMENTS_DRIVER=fake` — the app then shows a labelled test sheet.
    required String provider,
    required String clientSecret,
    required String publishableKey,
    required String merchantName,
    required double amount,
    required String currency,
  }) = _PaymentSheetDetails;

  factory PaymentSheetDetails.fromJson(Map<String, dynamic> json) => _$PaymentSheetDetailsFromJson(json);

  bool get isTest => provider == 'fake';
}
