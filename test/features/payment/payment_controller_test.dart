import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/api_exception.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/features/payment/payment_controller.dart';
import 'package:saints_link/src/features/payment/payment_service.dart';
import 'package:saints_link/src/features/trips/trips_controller.dart';

import '../../support/fakes.dart';

void main() {
  late FakeBookingRepository bookings;

  ProviderContainer containerWith(FakePaymentService payments) =>
      ProviderContainer.test(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(bookings),
          paymentServiceProvider.overrideWithValue(payments),
          paymentWebhookGraceProvider.overrideWithValue(Duration.zero),
        ],
      );

  setUp(() => bookings = FakeBookingRepository()..nextBooking = bookingWith());

  test('a completed sheet marks the booking paid and refetches it', () async {
    final payments = FakePaymentService(PaymentOutcome.paid);
    final container = containerWith(payments);
    final provider = paymentControllerProvider('SL-TEST');

    // Prime the trip so we can see it being refetched.
    final subscription = container.listen(
      tripDetailProvider('SL-TEST'),
      (_, _) {},
    );
    await container.read(tripDetailProvider('SL-TEST').future);
    bookings.nextBooking = bookingWith(canPay: false);

    final outcome = await container
        .read(provider.notifier)
        .pay(presentTestSheet: (_) async => true);

    expect(outcome, PaymentOutcome.paid);
    expect(container.read(provider).isPaid, isTrue);
    expect(payments.paidReferences, ['SL-TEST']);
    // The server, not the sheet, has the last word on payment status.
    expect(
      (await container.read(tripDetailProvider('SL-TEST').future)).canPay,
      isFalse,
    );
    subscription.close();
  });

  test('a dismissed sheet leaves the state idle with no error', () async {
    final container = containerWith(
      FakePaymentService(PaymentOutcome.cancelled),
    );
    final provider = paymentControllerProvider('SL-TEST');

    expect(
      await container
          .read(provider.notifier)
          .pay(presentTestSheet: (_) async => true),
      PaymentOutcome.cancelled,
    );
    expect(container.read(provider), const PaymentState());
  });

  test('an API failure is surfaced as the error to show', () async {
    final container = containerWith(
      FakePaymentService(
        PaymentOutcome.paid,
        error: const ApiException(
          'Online payment is temporarily unavailable.',
          statusCode: 503,
        ),
      ),
    );
    final provider = paymentControllerProvider('SL-TEST');

    expect(
      await container
          .read(provider.notifier)
          .pay(presentTestSheet: (_) async => true),
      PaymentOutcome.failed,
    );
    expect(
      container.read(provider).error,
      'Online payment is temporarily unavailable.',
    );
    expect(container.read(provider).isPaying, isFalse);
  });

  test('each booking has its own payment state', () async {
    final container = containerWith(FakePaymentService(PaymentOutcome.paid));

    await container
        .read(paymentControllerProvider('SL-A').notifier)
        .pay(presentTestSheet: (_) async => true);

    expect(container.read(paymentControllerProvider('SL-A')).isPaid, isTrue);
    expect(container.read(paymentControllerProvider('SL-B')).isPaid, isFalse);
  });
}
