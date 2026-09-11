import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';

/// The outcome of a payment attempt, as the screen needs to react to it.
enum PaymentOutcome { paid, cancelled, failed }

/// Taking a card in the app with Stripe's native payment sheet.
///
/// The server creates the PaymentIntent and hands back a client secret; the
/// sheet completes it directly with Stripe; the server learns the outcome from
/// Stripe's webhook, not from this app. That last point matters: the app's
/// "paid" is optimistic, and the booking's real paid state is whatever the
/// server says the next time it is fetched.
class PaymentService {
  PaymentService(this._ref);

  final Ref _ref;
  String? _configuredKey;

  Future<PaymentOutcome> payForBooking(String reference) async {
    final details = await _ref.read(bookingRepositoryProvider).paymentIntent(reference);

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
        googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'GB', currencyCode: 'GBP'),
      ),
    );

    try {
      await Stripe.instance.presentPaymentSheet();

      return PaymentOutcome.paid;
    } on StripeException catch (error) {
      if (error.error.code == FailureCode.Canceled) return PaymentOutcome.cancelled;

      throw ApiException(error.error.localizedMessage ?? 'Your payment could not be taken.');
    }
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) => PaymentService(ref));
