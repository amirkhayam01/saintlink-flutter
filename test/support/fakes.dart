import 'package:flutter/material.dart' show TimeOfDay;
import 'package:saints_link/src/core/api_exception.dart';
import 'package:saints_link/src/domain/booking.dart';
import 'package:saints_link/src/domain/customer.dart';
import 'package:saints_link/src/domain/page_meta.dart';
import 'package:saints_link/src/domain/payment_sheet_details.dart';
import 'package:saints_link/src/domain/place.dart';
import 'package:saints_link/src/domain/quote.dart';
import 'package:saints_link/src/domain/vehicle_category.dart';
import 'package:saints_link/src/features/auth/auth_repository.dart';
import 'package:saints_link/src/features/booking/booking_repository.dart';
import 'package:saints_link/src/features/booking/journey_draft.dart';
import 'package:saints_link/src/features/payment/payment_service.dart';

import '../fixtures/fixtures.dart';

/*
 * Hand-rolled fakes rather than a mocking library: the repositories have a
 * handful of methods each, and a fake that records calls and returns what the
 * test scripted is easier to read than mockito stubs.
 */

const customer = Customer(
  id: 1,
  name: 'Ada Lovelace',
  firstName: 'Ada',
  lastName: 'Lovelace',
  email: 'ada@example.com',
  phone: '+447700900000',
  maskedPhone: '+44 •••• ••0000',
  marketingConsent: false,
);

final quotableJourney = JourneyDraft(
  pickup: const PlaceSelection(address: 'Southampton Central Station', placeId: 'p1', latitude: 50.9, longitude: -1.4),
  dropoff: const PlaceSelection(address: 'Heathrow Airport Terminal 5'),
  pickupDate: DateTime(2026, 10, 1),
  pickupTime: const TimeOfDay(hour: 9, minute: 0),
  passengerCount: 2,
  luggageCount: 1,
);

/// The live quote fixture, with its expiry moved so the test controls it.
Quote quoteExpiringIn(Duration duration) =>
    Quote.fromJson(loadFixture('quote')).copyWith(expiresAt: DateTime.now().add(duration));

List<VehicleCategory> fixtureVehicles() => (loadFixture('vehicle_categories')['data'] as List<dynamic>)
    .map((item) => VehicleCategory.fromJson(item as Map<String, dynamic>))
    .toList();

Booking bookingWith({String reference = 'SL-TEST', bool canPay = true}) => Booking(
      reference: reference,
      status: 'awaiting_payment',
      statusLabel: 'Awaiting payment',
      paymentStatus: 'unpaid',
      paymentStatusLabel: 'Unpaid',
      totalAmount: 125,
      currency: 'GBP',
      journeyType: 'one_way',
      canPay: canPay,
      isCancellable: true,
    );

class FakeBookingRepository implements BookingRepository {
  Quote? nextQuote;
  ApiException? quoteError;
  Booking? nextBooking;
  ApiException? bookingError;
  List<VehicleCategory> vehicles = const [];

  final quoteRequests = <Map<String, dynamic>>[];
  final bookingRequests = <Map<String, dynamic>>[];

  /// Pages of bookings for `myBookings`, index 0 being page 1. When unset,
  /// a single page holding [nextBooking] if there is one.
  List<List<Booking>>? pages;
  ApiException? pageError;
  final pagesRequested = <int>[];

  @override
  Future<List<VehicleCategory>> vehicleCategories() async => vehicles;

  @override
  Future<Quote> requestQuote(JourneyDraft journey) async {
    quoteRequests.add(journey.toQuotePayload());
    if (quoteError != null) throw quoteError!;

    return nextQuote!;
  }

  @override
  Future<Booking> createBooking({
    required JourneyDraft journey,
    required String quoteToken,
    required String vehicleCategorySlug,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? specialInstructions,
  }) async {
    bookingRequests.add(journey.toBookingPayload(
      quoteToken: quoteToken,
      vehicleCategorySlug: vehicleCategorySlug,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      specialInstructions: specialInstructions,
    ));
    if (bookingError != null) throw bookingError!;

    return nextBooking!;
  }

  @override
  Future<Paginated<Booking>> myBookings({int page = 1}) async {
    pagesRequested.add(page);
    if (pageError != null && page > 1) throw pageError!;
    final all = pages ?? [[?nextBooking]];

    return Paginated(
      items: all[page - 1],
      meta: PageMeta(currentPage: page, lastPage: all.length, total: all.fold(0, (n, p) => n + p.length)),
    );
  }

  @override
  Future<Booking> booking(String reference) async => nextBooking!;

  @override
  Future<Booking> requestCancellation({required String reference, required String reason, String scope = 'booking', int? bookingLegId}) async =>
      nextBooking!;

  @override
  Future<PaymentSheetDetails> paymentIntent(String reference) async => throw UnimplementedError();
}

class FakeAuthRepository implements AuthRepository {
  bool hasSession = false;
  ApiException? meError;
  ApiException? updateError;
  int signOutCalls = 0;
  final profileUpdates = <Map<String, Object?>>[];

  @override
  Future<bool> hasStoredSession() async => hasSession;

  @override
  Future<Customer> me() async {
    if (meError != null) throw meError!;

    return customer;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    hasSession = false;
  }

  @override
  Future<SignInCodeRequest> requestCode(String phone) async => throw UnimplementedError();

  @override
  Future<Customer> verifyCode({required String phone, required String code, String? name, String deviceName = 'mobile'}) async =>
      throw UnimplementedError();

  @override
  Future<Customer> updateProfile({String? firstName, String? lastName, String? email, bool? marketingConsent}) async {
    profileUpdates.add({'first_name': firstName, 'last_name': lastName, 'email': email, 'marketing_consent': marketingConsent});
    if (updateError != null) throw updateError!;

    return customer.copyWith(
      firstName: firstName ?? customer.firstName,
      lastName: lastName,
      name: '${firstName ?? customer.firstName} ${lastName ?? ''}'.trim(),
      email: email,
      marketingConsent: marketingConsent ?? customer.marketingConsent,
    );
  }
}

class FakePaymentService implements PaymentService {
  FakePaymentService(this.outcome, {this.error});

  final PaymentOutcome outcome;
  final ApiException? error;
  final paidReferences = <String>[];

  @override
  Future<PaymentOutcome> payForBooking(String reference) async {
    if (error != null) throw error!;
    paidReferences.add(reference);

    return outcome;
  }
}
