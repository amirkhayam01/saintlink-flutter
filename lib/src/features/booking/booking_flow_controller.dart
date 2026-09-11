import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../domain/booking.dart';
import '../../domain/quote.dart';
import '../../domain/vehicle_category.dart';
import 'journey_draft.dart';

part 'booking_flow_controller.freezed.dart';

/// Everything the booking screens share, from the first address to the
/// confirmed booking.
///
/// One object rather than per-screen state so that going back a step never
/// loses what was typed, and so that the quote and the journey it was priced
/// for can never drift apart — see [JourneyDraft] for why that matters.
@freezed
abstract class BookingFlowState with _$BookingFlowState {
  const BookingFlowState._();

  const factory BookingFlowState({
    @Default(JourneyDraft()) JourneyDraft journey,
    Quote? quote,
    @Default([]) List<VehicleCategory> vehicles,
    @Default(false) bool isQuoting,
    String? quoteError,
    @Default(false) bool isBooking,
    String? bookingError,
    @Default({}) Map<String, List<String>> fieldErrors,

    /// Set once the booking has been created; the confirmation screen reads it.
    Booking? booking,
  }) = _BookingFlowState;

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
      final vehicles = await ref.read(bookingRepositoryProvider).vehicleCategories();
      // Read `state` only after the await: the receiver of `state.copyWith`
      // would otherwise be captured before the request and overwrite a quote
      // that arrived while the fleet was still loading.
      state = state.copyWith(vehicles: vehicles);
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
      quote: null,
      quoteError: null,
      bookingError: null,
      fieldErrors: const {},
    );
  }

  Future<bool> requestQuote() async {
    if (!state.journey.isQuotable) return false;

    state = state.copyWith(isQuoting: true, quoteError: null, quote: null);

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

    state = state.copyWith(isBooking: true, bookingError: null, fieldErrors: const {});

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
