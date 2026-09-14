import '../../core/api_exception.dart';
import '../../domain/booking.dart';
import '../../domain/customer.dart';
import '../../domain/page_meta.dart';
import '../../domain/payment_sheet_details.dart';
import '../booking/booking_repository.dart';
import '../booking/journey_draft.dart';
import 'auth_repository.dart';
import 'demo_session.dart';

class DemoAuthRepository extends AuthRepository {
  DemoAuthRepository({
    required super.api,
    required super.tokens,
    required this.session,
  });
  final DemoSessionController session;

  @override
  Future<Customer> me() async => session.customer;

  @override
  Future<Customer> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    bool? marketingConsent,
  }) async {
    final current = session.customer;
    final first = firstName ?? current.firstName;
    // Profile submits null to clear optional fields.
    final customer = current.copyWith(
      firstName: first,
      lastName: lastName,
      name: [first, lastName ?? ''].where((part) => part.isNotEmpty).join(' '),
      email: email,
      marketingConsent: marketingConsent ?? current.marketingConsent,
    );
    session.update(customer);
    return customer;
  }

  @override
  Future<void> signOut() async => session.end();

  @override
  Future<bool> hasStoredSession() async => false;
}

/// Public fleet/pricing calls still work, while preview account operations
/// remain local and cannot create, cancel, or pay for real bookings.
class DemoBookingRepository extends BookingRepository {
  DemoBookingRepository(super.api) : _trips = demoTrips();
  final List<Booking> _trips;

  @override
  Future<Paginated<Booking>> myBookings({int page = 1}) async => Paginated(
    items: page == 1 ? _trips : [],
    meta: PageMeta(currentPage: page, lastPage: 1, total: _trips.length),
  );

  @override
  Future<Booking> booking(String reference) async => _trips.firstWhere(
    (trip) => trip.reference == reference,
    orElse: () => throw const ApiException('Demo trip not found.'),
  );

  static Never _previewOnly() => throw const ApiException(
    'Sign out of demo mode and sign in to manage real bookings.',
  );

  @override
  Future<Booking> createBooking({
    required JourneyDraft journey,
    required String quoteToken,
    required String vehicleCategorySlug,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? specialInstructions,
  }) async => _previewOnly();

  @override
  Future<Booking> requestCancellation({
    required String reference,
    required String reason,
    String scope = 'booking',
    int? bookingLegId,
  }) async => _previewOnly();

  @override
  Future<PaymentSheetDetails> paymentIntent(String reference) async =>
      _previewOnly();

  @override
  Future<Booking> confirmTestPayment(String reference) async => _previewOnly();
}
