import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../domain/booking.dart';
import '../../domain/quote.dart';
import '../../domain/vehicle_category.dart';
import '../places/recent_places.dart';
import 'journey_draft.dart';

part 'booking_flow_controller.freezed.dart';

/// Everything the booking screens share, so a quote and the journey it priced never drift apart.
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
  List<VehicleCategory> get availableVehicles => vehicles
      .where((vehicle) => quote?.isAvailable(vehicle.slug) ?? false)
      .toList();

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

  String? get suggestedVehicleSlug {
    String? slug;
    double? cheapest;
    for (final vehicle in availableVehicles) {
      final fare = quote!.fareFor(vehicle.slug)!;
      final price = journey.isReturn ? fare.returnTotal : fare.single;
      if (price != null &&
          vehicle.fits(
            passengers: journey.passengerCount,
            luggage: journey.luggageCount,
          ) &&
          (cheapest == null || price < cheapest)) {
        cheapest = price;
        slug = vehicle.slug;
      }
    }
    return slug;
  }
}

class BookingFlowController extends Notifier<BookingFlowState> {
  int _resetGeneration = 0;
  @override
  BookingFlowState build() {
    Future.microtask(loadVehicles);

    return const BookingFlowState();
  }

  Future<void> loadVehicles({bool force = false}) async {
    if (!force && state.vehicles.isNotEmpty) return;

    try {
      final vehicles = await ref
          .read(bookingRepositoryProvider)
          .vehicleCategories();
      // `state` must be read after the await, or a quote that arrived meanwhile is overwritten.
      state = state.copyWith(vehicles: vehicles);
    } on ApiException {
      if (force) rethrow;
      // The fleet is decorative until a quote exists; the quote will surface
      // any real connectivity problem with a message the customer can act on.
    }
  }

  /// Any change discards the quote: the server fingerprints the journey it priced.
  void updateJourney(JourneyDraft Function(JourneyDraft) update) {
    _resetGeneration++;
    state = state.copyWith(
      journey: update(state.journey),
      quote: null,
      isQuoting: false,
      quoteError: null,
      bookingError: null,
      fieldErrors: const {},
    );
  }

  /// Flight information is excluded from the server's journey signature.
  /// Adding it at Details keeps the selected vehicle and its agreed quote.
  void updateFlightDetails({String? flightNumber, String? terminal}) {
    state = state.copyWith(
      journey: state.journey.copyWith(
        outboundFlightNumber:
            flightNumber ?? state.journey.outboundFlightNumber,
        outboundTerminal: terminal ?? state.journey.outboundTerminal,
      ),
      bookingError: null,
      fieldErrors: const {},
    );
  }

  Future<bool> requestQuote() async {
    if (!state.journey.isQuotable) return false;

    final generation = _resetGeneration;
    state = state.copyWith(isQuoting: true, quoteError: null, quote: null);

    try {
      if (state.vehicles.isEmpty) await loadVehicles(force: true);
      if (generation != _resetGeneration) return false;
      final quote = await ref
          .read(bookingRepositoryProvider)
          .requestQuote(state.journey);
      if (generation != _resetGeneration) return false;
      final priced = state.copyWith(quote: quote, isQuoting: false);
      // Every fresh quote starts with the cheapest vehicle that can carry
      // this party, including after luggage is reduced on the Journey step.
      state = priced.copyWith(
        journey: priced.journey.copyWith(
          vehicleCategorySlug: priced.suggestedVehicleSlug,
        ),
      );

      return true;
    } on ApiException catch (error) {
      if (generation != _resetGeneration) return false;
      state = state.copyWith(
        isQuoting: false,
        quoteError: error.message,
        fieldErrors: error.fieldErrors,
      );

      return false;
    }
  }

  void selectVehicle(String slug) {
    state = state.copyWith(
      journey: state.journey.copyWith(vehicleCategorySlug: slug),
    );
  }

  Future<Booking?> confirmBooking({
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? specialInstructions,
  }) async {
    final generation = _resetGeneration;
    final quote = state.quote;
    final slug = state.journey.vehicleCategorySlug;

    if (quote == null || slug == null) return null;

    if (quote.hasExpired) {
      state = state.copyWith(
        bookingError: 'Your quote has expired. Please refresh the price.',
      );

      return null;
    }

    state = state.copyWith(
      isBooking: true,
      bookingError: null,
      fieldErrors: const {},
    );

    try {
      final booking = await ref
          .read(bookingRepositoryProvider)
          .createBooking(
            journey: state.journey,
            quoteToken: quote.token,
            vehicleCategorySlug: slug,
            customerName: customerName,
            customerPhone: customerPhone,
            customerEmail: customerEmail,
            specialInstructions: specialInstructions,
          );

      if (generation != _resetGeneration) return null;
      state = state.copyWith(isBooking: false, booking: booking);
      // The server has just recorded both ends of this journey.
      ref.invalidate(customerPlacesProvider);

      return booking;
    } on ApiException catch (error) {
      if (generation != _resetGeneration) return null;
      state = state.copyWith(
        isBooking: false,
        bookingError: error.message,
        fieldErrors: error.fieldErrors,
      );

      return null;
    }
  }

  /// Start a fresh booking, keeping the fleet list.
  void reset() {
    _resetGeneration++;
    state = BookingFlowState(vehicles: state.vehicles);
  }
}

final bookingFlowProvider =
    NotifierProvider<BookingFlowController, BookingFlowState>(
      BookingFlowController.new,
    );
