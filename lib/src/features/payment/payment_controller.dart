import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/api_exception.dart';
import '../trips/trips_controller.dart';
import 'payment_service.dart';

part 'payment_controller.freezed.dart';

enum PaymentStatus { idle, paying, paid }

@freezed
abstract class PaymentState with _$PaymentState {
  const PaymentState._();

  const factory PaymentState({
    @Default(PaymentStatus.idle) PaymentStatus status,
    String? error,
  }) = _PaymentState;

  bool get isPaying => status == PaymentStatus.paying;

  bool get isPaid => status == PaymentStatus.paid;
}

/// How long to give Stripe's webhook to reach the server before the booking
/// is refetched. Overridden to zero in tests.
final paymentWebhookGraceProvider = Provider<Duration>((_) => const Duration(seconds: 2));

/// Paying for one booking, shared by every screen that offers a pay button.
///
/// Keyed by booking reference so the confirmation screen and the trip detail
/// screen see the same state if the customer moves between them mid-payment.
/// After a successful sheet the booking is refetched: the app's "paid" is
/// optimistic and the server's payment status, set by the webhook, is the one
/// that counts.
class PaymentController extends Notifier<PaymentState> {
  PaymentController(this.reference);

  final String reference;

  @override
  PaymentState build() => const PaymentState();

  Future<PaymentOutcome> pay() async {
    state = const PaymentState(status: PaymentStatus.paying);

    try {
      final outcome = await ref.read(paymentServiceProvider).payForBooking(reference);

      switch (outcome) {
        case PaymentOutcome.paid:
          state = const PaymentState(status: PaymentStatus.paid);
          await _refreshBooking();
        case PaymentOutcome.cancelled:
          state = const PaymentState();
        case PaymentOutcome.failed:
          state = const PaymentState(error: 'Your payment could not be taken. Please try again.');
      }

      return outcome;
    } on ApiException catch (error) {
      state = PaymentState(error: error.message);

      return PaymentOutcome.failed;
    }
  }

  /// The webhook can land a moment after the sheet closes. A short wait before
  /// refetching means the screen usually shows "Paid" first time rather than
  /// making the customer pull to refresh.
  Future<void> _refreshBooking() async {
    await Future<void>.delayed(ref.read(paymentWebhookGraceProvider));
    ref.invalidate(tripDetailProvider(reference));
    ref.invalidate(tripsProvider);
  }
}

final paymentControllerProvider =
    NotifierProvider.family<PaymentController, PaymentState, String>(PaymentController.new);
