import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/domain/payment_sheet_details.dart';
import 'package:saints_link/src/features/payment/payment_service.dart';

import '../../support/fakes.dart';

/// The Stripe path needs a device and is not unit-tested; the fake-driver
/// path is, because it is what every tester will use until Stripe is live.
void main() {
  const testSheet = PaymentSheetDetails(
    provider: 'fake',
    clientSecret: 'fake_pi_x_secret_y',
    publishableKey: '',
    merchantName: 'Saints Link',
    amount: 125,
    currency: 'GBP',
  );

  late FakeBookingRepository bookings;

  setUp(() => bookings = FakeBookingRepository()
    ..sheet = testSheet
    ..nextBooking = bookingWith());

  test('a test sheet the customer accepts is confirmed with the server', () async {
    PaymentSheetDetails? shown;

    final outcome = await PaymentService(bookings).payForBooking('SL-TEST', presentTestSheet: (details) async {
      shown = details;

      return true;
    });

    expect(outcome, PaymentOutcome.paid);
    expect(shown?.isTest, isTrue);
    expect(bookings.confirmedTestPayments, ['SL-TEST']);
  });

  test('a test sheet the customer dismisses confirms nothing', () async {
    final outcome = await PaymentService(bookings).payForBooking('SL-TEST', presentTestSheet: (_) async => false);

    expect(outcome, PaymentOutcome.cancelled);
    expect(bookings.confirmedTestPayments, isEmpty);
  });

  test('a real provider never shows the test sheet', () {
    expect(testSheet.copyWith(provider: 'stripe').isTest, isFalse);
  });
}
