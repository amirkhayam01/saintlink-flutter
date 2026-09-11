import 'package:flutter/material.dart' show TimeOfDay;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/place.dart';

part 'journey_draft.freezed.dart';

/// The journey being built, and the single source of the request payload.
///
/// This is the most important object in the app, for a reason that is not
/// obvious: the server fingerprints the journey when it prices it, and refuses
/// the booking if the fingerprint no longer matches when the customer confirms.
/// Whitespace, a changed passenger count, a re-typed address — any of it ends
/// the match and costs the customer their quote.
///
/// So the payload is built here, once, and both the quote request and the
/// booking request are derived from [_journeyFields]. Screens change this
/// object; they never assemble a request of their own. If a field must be added
/// to one call, it belongs in [_journeyFields] or in neither.
@freezed
abstract class JourneyDraft with _$JourneyDraft {
  const JourneyDraft._();

  const factory JourneyDraft({
    @Default(PlaceSelection.empty) PlaceSelection pickup,
    @Default(PlaceSelection.empty) PlaceSelection dropoff,
    @Default([]) List<PlaceSelection> via,
    DateTime? pickupDate,
    TimeOfDay? pickupTime,
    @Default(false) bool isReturn,
    DateTime? returnDate,
    TimeOfDay? returnTime,
    @Default(1) int passengerCount,
    @Default(0) int luggageCount,
    String? outboundFlightNumber,
    String? outboundTerminal,
    String? returnFlightNumber,
    String? returnTerminal,
    String? vehicleCategorySlug,
  }) = _JourneyDraft;

  /// Whether there is enough here to ask for a price.
  bool get isQuotable =>
      !pickup.isEmpty &&
      !dropoff.isEmpty &&
      pickup.address.trim().toLowerCase() != dropoff.address.trim().toLowerCase() &&
      pickupDate != null &&
      pickupTime != null &&
      (!isReturn || (returnDate != null && returnTime != null));

  /// True when either end is an airport, which is when asking for a flight
  /// number is worth the extra step.
  bool get touchesAirport =>
      pickup.address.toLowerCase().contains('airport') ||
      dropoff.address.toLowerCase().contains('airport');

  bool get isAirportPickup => pickup.address.toLowerCase().contains('airport');

  /// The journey fields, exactly as the server names them.
  ///
  /// Shared by both requests so the fingerprint the server computes at booking
  /// time is the one it computed when it priced the quote.
  Map<String, dynamic> _journeyFields() {
    return <String, dynamic>{
      'pickup_address': pickup.address.trim(),
      if (pickup.placeId != null) 'pickup_place_id': pickup.placeId,
      if (pickup.latitude != null) 'pickup_lat': pickup.latitude,
      if (pickup.longitude != null) 'pickup_lng': pickup.longitude,
      'dropoff_address': dropoff.address.trim(),
      if (dropoff.placeId != null) 'dropoff_place_id': dropoff.placeId,
      if (dropoff.latitude != null) 'dropoff_lat': dropoff.latitude,
      if (dropoff.longitude != null) 'dropoff_lng': dropoff.longitude,
      'via_addresses': via.map((stop) => stop.address.trim()).toList(),
      'via_waypoints': via
          .map((stop) => <String, dynamic>{
                'place_id': stop.placeId,
                'lat': stop.latitude,
                'lng': stop.longitude,
              })
          .toList(),
      'pickup_date': _formatDate(pickupDate!),
      'pickup_time': _formatTime(pickupTime!),
      'journey_type': isReturn ? 'return' : 'one_way',
      if (isReturn) 'return_date': _formatDate(returnDate!),
      if (isReturn) 'return_time': _formatTime(returnTime!),
      'passenger_count': passengerCount,
      'luggage_count': luggageCount,
      if (_isFilled(outboundFlightNumber)) 'outbound_flight_number': outboundFlightNumber!.trim(),
      if (_isFilled(outboundTerminal)) 'outbound_terminal': outboundTerminal!.trim(),
      if (_isFilled(returnFlightNumber)) 'return_flight_number': returnFlightNumber!.trim(),
      if (_isFilled(returnTerminal)) 'return_terminal': returnTerminal!.trim(),
    };
  }

  Map<String, dynamic> toQuotePayload() => _journeyFields();

  /// The booking request: the same journey, plus who is travelling.
  ///
  /// The vehicle is required here and absent from the quote, because the quote
  /// prices every vehicle and the customer picks one afterwards. It is not part
  /// of the fingerprint, so adding it does not invalidate the quote.
  Map<String, dynamic> toBookingPayload({
    required String quoteToken,
    required String vehicleCategorySlug,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? specialInstructions,
  }) {
    return <String, dynamic>{
      ..._journeyFields(),
      'quote_token': quoteToken,
      'vehicle_category': vehicleCategorySlug,
      'customer_name': customerName.trim(),
      'customer_phone': customerPhone.trim(),
      if (_isFilled(customerEmail)) 'customer_email': customerEmail!.trim().toLowerCase(),
      if (_isFilled(specialInstructions)) 'special_instructions': specialInstructions!.trim(),
      'terms_accepted': true,
    };
  }

  /// A return journey that is switched off keeps no stale dates behind it.
  JourneyDraft withoutReturn() => copyWith(
        isReturn: false,
        returnDate: null,
        returnTime: null,
        returnFlightNumber: null,
        returnTerminal: null,
      );

  static bool _isFilled(String? value) => value != null && value.trim().isNotEmpty;

  /// Formatted by hand, not with intl: the server parses these in Europe/London
  /// and expects a plain calendar date and wall-clock time, so a locale-aware
  /// formatter is exactly the wrong tool.
  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
