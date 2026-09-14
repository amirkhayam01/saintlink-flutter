import '../../core/api_client.dart';
import '../../domain/booking.dart';
import '../../domain/page_meta.dart';
import '../../domain/payment_sheet_details.dart';
import '../../domain/quote.dart';
import '../../domain/vehicle_category.dart';
import 'journey_draft.dart';

class BookingRepository {
  BookingRepository(this._api);

  final ApiClient _api;

  Future<List<VehicleCategory>> vehicleCategories() async {
    final response = await _api.get('/vehicle-categories');

    return (response['data'] as List<dynamic>)
        .map((item) => VehicleCategory.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Quote> requestQuote(JourneyDraft journey) async {
    final response = await _api.post('/quotes', body: journey.toQuotePayload());

    return Quote.fromJson(response);
  }

  Future<Booking> createBooking({
    required JourneyDraft journey,
    required String quoteToken,
    required String vehicleCategorySlug,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? specialInstructions,
  }) async {
    final response = await _api.post(
      '/bookings',
      body: journey.toBookingPayload(
        quoteToken: quoteToken,
        vehicleCategorySlug: vehicleCategorySlug,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        specialInstructions: specialInstructions,
      ),
    );

    return Booking.fromJson(response['booking'] as Map<String, dynamic>);
  }

  /// Newest first, twenty to a page — the server's page size, not ours.
  Future<Paginated<Booking>> myBookings({int page = 1}) async {
    final response = await _api.get('/bookings', query: {'page': page});

    return Paginated(
      items: (response['data'] as List<dynamic>)
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: PageMeta.fromJson(response['meta'] as Map<String, dynamic>),
    );
  }

  Future<Booking> booking(String reference) async {
    final response = await _api.get('/bookings/$reference');

    return Booking.fromJson(response['booking'] as Map<String, dynamic>);
  }

  Future<Booking> requestCancellation({
    required String reference,
    required String reason,
    String scope = 'booking',
    int? bookingLegId,
  }) async {
    final response = await _api.post(
      '/bookings/$reference/cancellation-request',
      body: {'reason': reason, 'scope': scope, 'booking_leg_id': ?bookingLegId},
    );

    return Booking.fromJson(response['booking'] as Map<String, dynamic>);
  }

  Future<PaymentSheetDetails> paymentIntent(String reference) async {
    final response = await _api.post('/bookings/$reference/payment-intent');

    return PaymentSheetDetails.fromJson(response);
  }

  /// Settles a test payment. Only the fake driver accepts this; with Stripe
  /// the server answers 422 and the webhook remains the only way to be paid.
  Future<Booking> confirmTestPayment(String reference) async {
    final response = await _api.post(
      '/bookings/$reference/payment-intent/confirm-test',
    );

    return Booking.fromJson(response['booking'] as Map<String, dynamic>);
  }
}
