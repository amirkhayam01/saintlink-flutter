import 'package:flutter/material.dart';

/// One end of a journey, as the customer chose it.
@immutable
class PlaceSelection {
  const PlaceSelection({
    required this.address,
    this.placeId,
    this.latitude,
    this.longitude,
  });

  static const empty = PlaceSelection(address: '');

  final String address;
  final String? placeId;
  final double? latitude;
  final double? longitude;

  bool get isEmpty => address.trim().isEmpty;

  /// Whether the pricing engine can measure from this rather than guess.
  ///
  /// An address typed by hand and never picked from the suggestions has no
  /// coordinates. It can still be priced — the server falls back to matching
  /// the text against its own known locations — but far less precisely, so the
  /// form nudges the customer to choose a suggestion.
  bool get isLocated => latitude != null && longitude != null;

  PlaceSelection copyWith({
    String? address,
    String? placeId,
    double? latitude,
    double? longitude,
  }) {
    return PlaceSelection(
      address: address ?? this.address,
      placeId: placeId ?? this.placeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

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
@immutable
class JourneyDraft {
  const JourneyDraft({
    this.pickup = PlaceSelection.empty,
    this.dropoff = PlaceSelection.empty,
    this.via = const [],
    this.pickupDate,
    this.pickupTime,
    this.isReturn = false,
    this.returnDate,
    this.returnTime,
    this.passengerCount = 1,
    this.luggageCount = 0,
    this.outboundFlightNumber,
    this.outboundTerminal,
    this.returnFlightNumber,
    this.returnTerminal,
    this.vehicleCategorySlug,
  });

  final PlaceSelection pickup;
  final PlaceSelection dropoff;
  final List<PlaceSelection> via;
  final DateTime? pickupDate;
  final TimeOfDay? pickupTime;
  final bool isReturn;
  final DateTime? returnDate;
  final TimeOfDay? returnTime;
  final int passengerCount;
  final int luggageCount;
  final String? outboundFlightNumber;
  final String? outboundTerminal;
  final String? returnFlightNumber;
  final String? returnTerminal;
  final String? vehicleCategorySlug;

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

  JourneyDraft copyWith({
    PlaceSelection? pickup,
    PlaceSelection? dropoff,
    List<PlaceSelection>? via,
    DateTime? pickupDate,
    TimeOfDay? pickupTime,
    bool? isReturn,
    DateTime? returnDate,
    TimeOfDay? returnTime,
    int? passengerCount,
    int? luggageCount,
    String? outboundFlightNumber,
    String? outboundTerminal,
    String? returnFlightNumber,
    String? returnTerminal,
    String? vehicleCategorySlug,
  }) {
    return JourneyDraft(
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      via: via ?? this.via,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTime: pickupTime ?? this.pickupTime,
      isReturn: isReturn ?? this.isReturn,
      returnDate: returnDate ?? this.returnDate,
      returnTime: returnTime ?? this.returnTime,
      passengerCount: passengerCount ?? this.passengerCount,
      luggageCount: luggageCount ?? this.luggageCount,
      outboundFlightNumber: outboundFlightNumber ?? this.outboundFlightNumber,
      outboundTerminal: outboundTerminal ?? this.outboundTerminal,
      returnFlightNumber: returnFlightNumber ?? this.returnFlightNumber,
      returnTerminal: returnTerminal ?? this.returnTerminal,
      vehicleCategorySlug: vehicleCategorySlug ?? this.vehicleCategorySlug,
    );
  }

  /// A return journey that is switched off keeps no stale dates behind it.
  JourneyDraft withoutReturn() {
    return JourneyDraft(
      pickup: pickup,
      dropoff: dropoff,
      via: via,
      pickupDate: pickupDate,
      pickupTime: pickupTime,
      isReturn: false,
      passengerCount: passengerCount,
      luggageCount: luggageCount,
      outboundFlightNumber: outboundFlightNumber,
      outboundTerminal: outboundTerminal,
      vehicleCategorySlug: vehicleCategorySlug,
    );
  }

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
