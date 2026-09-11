import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/api_exception.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/features/booking/booking_flow_controller.dart';

import '../../support/fakes.dart';

void main() {
  late FakeBookingRepository bookings;
  late ProviderContainer container;

  setUp(() async {
    bookings = FakeBookingRepository()..vehicles = fixtureVehicles();
    container = ProviderContainer.test(overrides: [bookingRepositoryProvider.overrideWithValue(bookings)]);
    // First read kicks off the fleet load; let it land before each test.
    container.read(bookingFlowProvider);
    await Future<void>.delayed(Duration.zero);
  });

  BookingFlowController controller() => container.read(bookingFlowProvider.notifier);

  test('loads the fleet on first read', () {
    expect(container.read(bookingFlowProvider).vehicles.map((v) => v.slug), contains('saloon-car'));
  });

  test('a slow fleet response does not overwrite a quote that arrived first', () async {
    // Fresh container so the fleet is still in flight when the quote lands.
    bookings.nextQuote = quoteExpiringIn(const Duration(minutes: 30));
    final racing = ProviderContainer.test(overrides: [bookingRepositoryProvider.overrideWithValue(bookings)]);
    final notifier = racing.read(bookingFlowProvider.notifier);
    notifier.updateJourney((_) => quotableJourney);

    await notifier.requestQuote();
    await Future<void>.delayed(Duration.zero);

    final state = racing.read(bookingFlowProvider);
    expect(state.quote, isNotNull);
    expect(state.vehicles, isNotEmpty);
  });

  test('does not ask for a price until the journey is quotable', () async {
    expect(await controller().requestQuote(), isFalse);
    expect(bookings.quoteRequests, isEmpty);
  });

  test('a quote is priced from the draft and exposes only priceable vehicles', () async {
    bookings.nextQuote = quoteExpiringIn(const Duration(minutes: 30));
    controller().updateJourney((_) => quotableJourney);

    expect(await controller().requestQuote(), isTrue);

    final state = container.read(bookingFlowProvider);
    expect(state.quote, isNotNull);
    expect(state.isQuoting, isFalse);
    expect(state.availableVehicles.map((v) => v.slug), containsAll(['saloon-car', 'minibus-8']));
    expect(bookings.quoteRequests.single, quotableJourney.toQuotePayload());
  });

  test('editing the journey throws the quote away', () async {
    bookings.nextQuote = quoteExpiringIn(const Duration(minutes: 30));
    controller().updateJourney((_) => quotableJourney);
    await controller().requestQuote();

    controller().updateJourney((j) => j.copyWith(passengerCount: 3));

    // The server fingerprints the journey: a quote for two passengers cannot
    // be booked for three, so keeping it would only fail at the last step.
    expect(container.read(bookingFlowProvider).quote, isNull);
  });

  test('a quote failure keeps the message and field errors for the form', () async {
    bookings.quoteError = const ApiException('No vehicle can carry that party.', statusCode: 422, fieldErrors: {'passenger_count': ['Too many']});
    controller().updateJourney((_) => quotableJourney);

    expect(await controller().requestQuote(), isFalse);

    final state = container.read(bookingFlowProvider);
    expect(state.quoteError, 'No vehicle can carry that party.');
    expect(state.fieldErrors['passenger_count'], ['Too many']);
  });

  test('total due doubles up on a return journey', () async {
    bookings.nextQuote = quoteExpiringIn(const Duration(minutes: 30));
    controller().updateJourney((_) => quotableJourney.copyWith(isReturn: true, returnDate: DateTime(2026, 10, 5), returnTime: quotableJourney.pickupTime));
    await controller().requestQuote();
    controller().selectVehicle('saloon-car');

    expect(container.read(bookingFlowProvider).totalDue, 250);
  });

  test('refuses to book against an expired quote', () async {
    bookings.nextQuote = quoteExpiringIn(const Duration(seconds: -1));
    controller().updateJourney((_) => quotableJourney);
    await controller().requestQuote();
    controller().selectVehicle('saloon-car');

    final booking = await controller().confirmBooking(customerName: 'Ada', customerPhone: '07700900000');

    expect(booking, isNull);
    expect(container.read(bookingFlowProvider).bookingError, contains('expired'));
    expect(bookings.bookingRequests, isEmpty);
  });

  test('books with the same journey fields the quote was priced for', () async {
    bookings.nextQuote = quoteExpiringIn(const Duration(minutes: 30));
    bookings.nextBooking = bookingWith();
    controller().updateJourney((_) => quotableJourney);
    await controller().requestQuote();
    controller().selectVehicle('mpv-6');

    final booking = await controller().confirmBooking(customerName: 'Ada', customerPhone: '07700900000', customerEmail: 'ADA@example.com');

    expect(booking?.reference, 'SL-TEST');
    expect(container.read(bookingFlowProvider).booking, booking);

    final request = bookings.bookingRequests.single;
    expect(request['quote_token'], bookings.nextQuote!.token);
    expect(request['vehicle_category'], 'mpv-6');
    expect(request['customer_email'], 'ada@example.com');
    for (final entry in bookings.quoteRequests.single.entries) {
      expect(request[entry.key], entry.value, reason: entry.key);
    }
  });

  test('reset starts a fresh journey but keeps the fleet', () async {
    bookings.nextQuote = quoteExpiringIn(const Duration(minutes: 30));
    controller().updateJourney((_) => quotableJourney);
    await controller().requestQuote();

    controller().reset();

    final state = container.read(bookingFlowProvider);
    expect(state.quote, isNull);
    expect(state.journey.pickup.isEmpty, isTrue);
    expect(state.vehicles, isNotEmpty);
  });
}
