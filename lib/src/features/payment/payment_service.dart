import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../domain/payment_sheet_details.dart';
import '../booking/booking_repository.dart';

/// The outcome of a payment attempt, as the screen needs to react to it.
enum PaymentOutcome { paid, cancelled, failed }

/// Shows the test-payment sheet; only used while the backend runs the fake driver.
typedef PresentTestSheet = Future<bool> Function(PaymentSheetDetails details);

/// Stripe's native payment sheet. The server learns the outcome from the webhook, not from this app.
class PaymentService {
  PaymentService(this._bookings);

  final BookingRepository _bookings;
  String? _configuredKey;

  Future<PaymentOutcome> payForBooking(
    String reference, {
    required PresentTestSheet presentTestSheet,
  }) async {
    final details = await _bookings.paymentIntent(reference);

    if (details.isTest) {
      if (!await presentTestSheet(details)) return PaymentOutcome.cancelled;

      await _bookings.confirmTestPayment(reference);

      return PaymentOutcome.paid;
    }

    // The publishable key comes from the server so the app never has to be
    // rebuilt to move between Stripe test and live modes.
    if (_configuredKey != details.publishableKey) {
      Stripe.publishableKey = details.publishableKey;
      Stripe.merchantIdentifier = 'merchant.uk.co.saintslink';
      await Stripe.instance.applySettings();
      _configuredKey = details.publishableKey;
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: details.clientSecret,
        merchantDisplayName: details.merchantName,
        style: ThemeMode.light,
        applePay: const PaymentSheetApplePay(merchantCountryCode: 'GB'),
        googlePay: const PaymentSheetGooglePay(
          merchantCountryCode: 'GB',
          currencyCode: 'GBP',
        ),
      ),
    );

    try {
      await Stripe.instance.presentPaymentSheet();

      return PaymentOutcome.paid;
    } on StripeException catch (error) {
      if (error.error.code == FailureCode.Canceled) {
        return PaymentOutcome.cancelled;
      }

      throw ApiException(
        error.error.localizedMessage ?? 'Your payment could not be taken.',
      );
    }
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ref.watch(bookingRepositoryProvider));
});
