import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../trips/booking_models.dart';
import 'journey_draft.dart';
import 'models.dart';

/// Everything the booking screens share, from the first address to the
/// confirmed booking.
///
/// One object rather than per-screen state so that going back a step never
/// loses what was typed, and so that the quote and the journey it was priced
/// for can never drift apart — see [JourneyDraft] for why that matters.
@immutable
class BookingFlowState {
  const BookingFlowState({
    this.journey = const JourneyDraft(),
    this.quote,
    this.vehicles = const [],
    this.isQuoting = false,
    this.quoteError,
    this.isBooking = false,
    this.bookingError,
    this.fieldErrors = const {},
    this.booking,
  });

  final JourneyDraft journey;
  final Quote? quote;
  final List<VehicleCategory> vehicles;
  final bool isQuoting;
  final String? quoteError;
  final bool isBooking;
  final String? bookingError;
  final Map<String, List<String>> fieldErrors;

  /// Set once the booking has been created; the confirmation screen reads it.
  final Booking? booking;

  /// Vehicles the customer can actually pick: in the quote, with a price.
  List<VehicleCategory> get availableVehicles =>
      vehicles.where((vehicle) => quote?.isAvailable(vehicle.slug) ?? false).toList();

  VehicleCategory? get selectedVehicle {
    final slug = journey.vehicleCategorySlug;
    if (slug == null) return null;

    for (final vehicle in vehicles) {
      if (vehicle.slug == slug) return vehicle;
    }

    return null;
  }

  Fare? get selectedFare {
    final slug = journey.vehicleCategorySlug;

    return slug == null ? null : quote?.fareFor(slug);
  }

  /// The amount due for the journey as configured: both legs on a return.
  double? get totalDue {
    final fare = selectedFare;
    if (fare == null) return null;

    return journey.isReturn ? fare.returnTotal : fare.single;
  }

  BookingFlowState copyWith({
    JourneyDraft? journey,
    Quote? quote,
    bool clearQuote = false,
    List<VehicleCategory>? vehicles,
    bool? isQuoting,
    String? quoteError,
    bool clearQuoteError = false,
    bool? isBooking,
    String? bookingError,
    bool clearBookingError = false,
    Map<String, List<String>>? fieldErrors,
    Booking? booking,
  }) {
    return BookingFlowState(
      journey: journey ?? this.journey,
      quote: clearQuote ? null : (quote ?? this.quote),
      vehicles: vehicles ?? this.vehicles,
      isQuoting: isQuoting ?? this.isQuoting,
      quoteError: clearQuoteError ? null : (quoteError ?? this.quoteError),
      isBooking: isBooking ?? this.isBooking,
      bookingError: clearBookingError ? null : (bookingError ?? this.bookingError),
      fieldErrors: fieldErrors ?? this.fieldErrors,
      booking: booking ?? this.booking,
    );
  }
}

class BookingFlowController extends Notifier<BookingFlowState> {
  @override
  BookingFlowState build() {
    Future.microtask(loadVehicles);

    return const BookingFlowState();
  }

  Future<void> loadVehicles() async {
    if (state.vehicles.isNotEmpty) return;

    try {
      state = state.copyWith(vehicles: await ref.read(bookingRepositoryProvider).vehicleCategories());
    } on ApiException {
      // The fleet is decorative until a quote exists; the quote will surface
      // any real connectivity problem with a message the customer can act on.
    }
  }

  /// Change the journey. Any existing quote is discarded, because it was priced
  /// for a journey that no longer exists — keeping it would let the customer
  /// reach checkout with a fingerprint the server will refuse.
  void updateJourney(JourneyDraft Function(JourneyDraft) update) {
    state = state.copyWith(
      journey: update(state.journey),
      clearQuote: true,
      clearQuoteError: true,
      clearBookingError: true,
      fieldErrors: const {},
    );
  }

  Future<bool> requestQuote() async {
    if (!state.journey.isQuotable) return false;

    state = state.copyWith(isQuoting: true, clearQuoteError: true, clearQuote: true);

    try {
      final quote = await ref.read(bookingRepositoryProvider).requestQuote(state.journey);
      final stillSelected = state.journey.vehicleCategorySlug;

      state = state.copyWith(
        quote: quote,
        isQuoting: false,
        // A vehicle chosen on a previous quote stays chosen only if this
        // quote can still offer it.
        journey: stillSelected != null && !quote.isAvailable(stillSelected)
            ? state.journey.copyWith(vehicleCategorySlug: _firstAvailable(quote))
            : state.journey,
      );

      return true;
    } on ApiException catch (error) {
      state = state.copyWith(isQuoting: false, quoteError: error.message, fieldErrors: error.fieldErrors);

      return false;
    }
  }

  void selectVehicle(String slug) {
    state = state.copyWith(journey: state.journey.copyWith(vehicleCategorySlug: slug));
  }

  Future<Booking?> confirmBooking({
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? specialInstructions,
  }) async {
    final quote = state.quote;
    final slug = state.journey.vehicleCategorySlug;

    if (quote == null || slug == null) return null;

    if (quote.hasExpired) {
      state = state.copyWith(bookingError: 'Your quote has expired. Please refresh the price.');

      return null;
    }

    state = state.copyWith(isBooking: true, clearBookingError: true, fieldErrors: const {});

    try {
      final booking = await ref.read(bookingRepositoryProvider).createBooking(
            journey: state.journey,
            quoteToken: quote.token,
            vehicleCategorySlug: slug,
            customerName: customerName,
            customerPhone: customerPhone,
            customerEmail: customerEmail,
            specialInstructions: specialInstructions,
          );

      state = state.copyWith(isBooking: false, booking: booking);

      return booking;
    } on ApiException catch (error) {
      state = state.copyWith(isBooking: false, bookingError: error.message, fieldErrors: error.fieldErrors);

      return null;
    }
  }

  /// Start again after a confirmed booking, keeping the fleet list.
  void reset() {
    state = BookingFlowState(vehicles: state.vehicles);
  }

  String? _firstAvailable(Quote quote) => quote.fares.keys.isEmpty ? null : quote.fares.keys.first;
}

final bookingFlowProvider =
    NotifierProvider<BookingFlowController, BookingFlowState>(BookingFlowController.new);
