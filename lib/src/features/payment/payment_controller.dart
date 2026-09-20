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
final paymentWebhookGraceProvider = Provider<Duration>(
  (_) => const Duration(seconds: 2),
);

/// Paying for one booking, keyed by reference so every screen sees the same state.
/// "Paid" is refetched from the server; the webhook decides, not the app.
class PaymentController extends Notifier<PaymentState> {
  PaymentController(this.reference);

  final String reference;

  @override
  PaymentState build() => const PaymentState();

  Future<PaymentOutcome> pay({
    required PresentTestSheet presentTestSheet,
  }) async {
    state = const PaymentState(status: PaymentStatus.paying);

    try {
      final outcome = await ref
          .read(paymentServiceProvider)
          .payForBooking(reference, presentTestSheet: presentTestSheet);

      switch (outcome) {
        case PaymentOutcome.paid:
          state = const PaymentState(status: PaymentStatus.paid);
          await _refreshBooking();
        case PaymentOutcome.cancelled:
          state = const PaymentState();
        case PaymentOutcome.failed:
          state = const PaymentState(
            error: 'Your payment could not be taken. Please try again.',
          );
      }

      return outcome;
    } on ApiException catch (error) {
      state = PaymentState(error: error.message);

      return PaymentOutcome.failed;
    }
  }

  /// A short wait so the webhook usually lands before the refetch.
  Future<void> _refreshBooking() async {
    await Future<void>.delayed(ref.read(paymentWebhookGraceProvider));
    ref.invalidate(tripDetailProvider(reference));
    ref.invalidate(tripsProvider);
  }
}

final paymentControllerProvider =
    NotifierProvider.family<PaymentController, PaymentState, String>(
      PaymentController.new,
    );
