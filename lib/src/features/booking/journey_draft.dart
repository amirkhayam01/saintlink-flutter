import 'package:flutter/material.dart' show TimeOfDay;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/place.dart';

part 'journey_draft.freezed.dart';

/// The journey being built, and the single source of both request payloads.
/// The server fingerprints what it priced and refuses a booking that differs, so
/// every field goes through [_journeyFields] or nowhere.
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

  /// Both ends named, and not the same place. The first half of the form
  /// is done when this is true; the price still needs a date.
  bool get hasRoute =>
      !pickup.isEmpty &&
      !dropoff.isEmpty &&
      pickup.address.trim().toLowerCase() !=
          dropoff.address.trim().toLowerCase();

  /// Both halves of the pickup moment are set.
  bool get hasPickupTime => pickupDate != null && pickupTime != null;

  /// The pickup moment, once both halves are set.
  DateTime? get pickupDateTime => hasPickupTime
      ? DateTime(
          pickupDate!.year,
          pickupDate!.month,
          pickupDate!.day,
          pickupTime!.hour,
          pickupTime!.minute,
        )
      : null;

  /// Whether there is enough here to ask for a price.
  bool get isQuotable =>
      hasRoute &&
      pickupDate != null &&
      pickupTime != null &&
      (!isReturn || (returnDate != null && returnTime != null));

  /// True when either end is an airport, which is when asking for a flight
  /// number is worth the extra step.
  bool get touchesAirport =>
      pickup.address.toLowerCase().contains('airport') ||
      dropoff.address.toLowerCase().contains('airport');

  bool get isAirportPickup => pickup.address.toLowerCase().contains('airport');

  /// The journey fields as the server names them, shared by both requests.
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
      'via_addresses': _filledVia.map((stop) => stop.address.trim()).toList(),
      'via_waypoints': _filledVia
          .map(
            (stop) => <String, dynamic>{
              'place_id': stop.placeId,
              'lat': stop.latitude,
              'lng': stop.longitude,
            },
          )
          .toList(),
      'pickup_date': _formatDate(pickupDate!),
      'pickup_time': _formatTime(pickupTime!),
      'journey_type': isReturn ? 'return' : 'one_way',
      if (isReturn) 'return_date': _formatDate(returnDate!),
      if (isReturn) 'return_time': _formatTime(returnTime!),
      'passenger_count': passengerCount,
      'luggage_count': luggageCount,
      if (_isFilled(outboundFlightNumber))
        'outbound_flight_number': outboundFlightNumber!.trim(),
      if (_isFilled(outboundTerminal))
        'outbound_terminal': outboundTerminal!.trim(),
      if (_isFilled(returnFlightNumber))
        'return_flight_number': returnFlightNumber!.trim(),
      if (_isFilled(returnTerminal)) 'return_terminal': returnTerminal!.trim(),
    };
  }

  /// Stops the customer added but never filled in are not part of the journey.
  Iterable<PlaceSelection> get _filledVia => via.where((stop) => !stop.isEmpty);

  Map<String, dynamic> toQuotePayload() => _journeyFields();

  /// The booking request: the journey plus vehicle and passenger. The vehicle is outside the fingerprint.
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
      if (_isFilled(customerEmail))
        'customer_email': customerEmail!.trim().toLowerCase(),
      if (_isFilled(specialInstructions))
        'special_instructions': specialInstructions!.trim(),
      'terms_accepted': true,
    };
  }

  /// The server's limit (`StoreQuoteRequest`: `via_addresses` max 5).
  static const maxViaStops = 5;

  bool get canAddViaStop => via.length < maxViaStops;

  /// Adds an empty stop for the customer to fill in. Empty stops are dropped
  /// from the payload, so an unfilled one never reaches the server.
  JourneyDraft addViaStop() => copyWith(via: [...via, PlaceSelection.empty]);

  JourneyDraft setViaStop(int index, PlaceSelection place) => copyWith(
    via: [for (var i = 0; i < via.length; i++) i == index ? place : via[i]],
  );

  JourneyDraft removeViaStop(int index) => copyWith(
    via: [
      for (var i = 0; i < via.length; i++)
        if (i != index) via[i],
    ],
  );

  /// A return journey that is switched off keeps no stale dates behind it.
  JourneyDraft withoutReturn() => copyWith(
    isReturn: false,
    returnDate: null,
    returnTime: null,
    returnFlightNumber: null,
    returnTerminal: null,
  );

  static bool _isFilled(String? value) =>
      value != null && value.trim().isNotEmpty;

  /// Plain calendar date and wall-clock time; a locale-aware formatter is the wrong tool.
  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
