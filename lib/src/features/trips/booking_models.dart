import 'package:flutter/foundation.dart';

/// A stop on a journey leg.
@immutable
class BookingStop {
  const BookingStop({required this.type, required this.address});

  factory BookingStop.fromJson(Map<String, dynamic> json) => BookingStop(
        type: json['type'] as String,
        address: json['address'] as String,
      );

  final String type;
  final String address;
}

/// The flight a leg is tied to, when there is one.
@immutable
class BookingFlight {
  const BookingFlight({required this.number, this.terminal, this.status});

  factory BookingFlight.fromJson(Map<String, dynamic> json) => BookingFlight(
        number: json['number'] as String,
        terminal: json['terminal'] as String?,
        status: json['status'] as String?,
      );

  final String number;
  final String? terminal;
  final String? status;
}

/// One movement: the outward journey, or the way back.
@immutable
class BookingLeg {
  const BookingLeg({
    required this.id,
    required this.direction,
    required this.status,
    required this.stops,
    required this.passengerCount,
    required this.includedWaitingMinutes,
    required this.meetAndGreet,
    this.pickupAt,
    this.requestedPickupAt,
    this.vehicle,
    this.distanceMiles,
    this.estimatedDurationMinutes,
    this.flight,
  });

  factory BookingLeg.fromJson(Map<String, dynamic> json) => BookingLeg(
        id: json['id'] as int,
        direction: json['direction'] as String,
        status: json['status'] as String,
        stops: (json['stops'] as List<dynamic>)
            .map((stop) => BookingStop.fromJson(stop as Map<String, dynamic>))
            .toList(),
        pickupAt: _parseDate(json['pickup_at']),
        requestedPickupAt: _parseDate(json['requested_pickup_at']),
        vehicle: json['vehicle'] as String?,
        passengerCount: json['passenger_count'] as int,
        includedWaitingMinutes: json['included_waiting_minutes'] as int,
        meetAndGreet: json['meet_and_greet'] as bool,
        distanceMiles: (json['distance_miles'] as num?)?.toDouble(),
        estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
        flight: json['flight'] == null
            ? null
            : BookingFlight.fromJson(json['flight'] as Map<String, dynamic>),
      );

  final int id;
  final String direction;
  final String status;
  final List<BookingStop> stops;

  /// What the customer should be ready for. On a tracked airport pickup this
  /// moves with the flight, while [requestedPickupAt] is what they chose.
  final DateTime? pickupAt;
  final DateTime? requestedPickupAt;
  final String? vehicle;
  final int passengerCount;
  final int includedWaitingMinutes;
  final bool meetAndGreet;
  final double? distanceMiles;
  final int? estimatedDurationMinutes;
  final BookingFlight? flight;

  bool get isReturnLeg => direction == 'return';

  /// True when flight tracking has moved the pickup away from the time the
  /// customer originally asked for — worth pointing out on screen.
  bool get pickupWasAdjusted =>
      pickupAt != null && requestedPickupAt != null && pickupAt != requestedPickupAt;

  String get pickupAddress =>
      stops.where((stop) => stop.type == 'pickup').firstOrNull?.address ??
      (stops.isEmpty ? '' : stops.first.address);

  String get dropoffAddress =>
      stops.where((stop) => stop.type == 'dropoff').firstOrNull?.address ??
      (stops.isEmpty ? '' : stops.last.address);

  List<BookingStop> get viaStops => stops.where((stop) => stop.type == 'via').toList();
}

@immutable
class FareItem {
  const FareItem({required this.label, required this.amount});

  factory FareItem.fromJson(Map<String, dynamic> json) => FareItem(
        label: json['label'] as String,
        amount: (json['amount'] as num).toDouble(),
      );

  final String label;
  final double amount;
}

@immutable
class CancellationRequestSummary {
  const CancellationRequestSummary({
    required this.status,
    required this.scope,
    required this.reason,
    required this.recommendedRefundPercentage,
  });

  factory CancellationRequestSummary.fromJson(Map<String, dynamic> json) =>
      CancellationRequestSummary(
        status: json['status'] as String,
        scope: json['scope'] as String,
        reason: json['reason'] as String,
        recommendedRefundPercentage: (json['recommended_refund_percentage'] as num).toDouble(),
      );

  final String status;
  final String scope;
  final String reason;
  final double recommendedRefundPercentage;
}

/// A booking, as the app shows it.
///
/// The list and the detail screen share this type: the list simply leaves the
/// deeper fields null, which keeps one model rather than two that drift.
@immutable
class Booking {
  const Booking({
    required this.reference,
    required this.status,
    required this.statusLabel,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.totalAmount,
    required this.currency,
    required this.canPay,
    required this.isCancellable,
    required this.journeyType,
    this.pickupAt,
    this.pickupAddress,
    this.dropoffAddress,
    this.vehicle,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerNotes,
    this.createdAt,
    this.cancelledAt,
    this.legs = const [],
    this.fareItems = const [],
    this.cancellationRequest,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        reference: json['reference'] as String,
        status: json['status'] as String,
        statusLabel: json['status_label'] as String,
        paymentStatus: json['payment_status'] as String,
        paymentStatusLabel: json['payment_status_label'] as String,
        totalAmount: (json['total_amount'] as num).toDouble(),
        currency: json['currency'] as String,
        canPay: json['can_pay'] as bool,
        isCancellable: json['is_cancellable'] as bool,
        journeyType: json['journey_type'] as String,
        pickupAt: _parseDate(json['pickup_at']),
        pickupAddress: json['pickup_address'] as String?,
        dropoffAddress: json['dropoff_address'] as String?,
        vehicle: json['vehicle'] as String?,
        customerName: json['customer_name'] as String?,
        customerPhone: json['customer_phone'] as String?,
        customerEmail: json['customer_email'] as String?,
        customerNotes: json['customer_notes'] as String?,
        createdAt: _parseDate(json['created_at']),
        cancelledAt: _parseDate(json['cancelled_at']),
        // `legs`, `fare_items` and the customer fields are only in the detail
        // payload; the list endpoint sends the summary without them.
        legs: (json['legs'] as List<dynamic>? ?? const [])
            .map((leg) => BookingLeg.fromJson(leg as Map<String, dynamic>))
            .toList(),
        fareItems: (json['fare_items'] as List<dynamic>? ?? const [])
            .map((item) => FareItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        cancellationRequest: json['cancellation_request'] == null
            ? null
            : CancellationRequestSummary.fromJson(
                json['cancellation_request'] as Map<String, dynamic>),
      );

  final String reference;
  final String status;
  final String statusLabel;
  final String paymentStatus;
  final String paymentStatusLabel;
  final double totalAmount;
  final String currency;
  final bool canPay;
  final bool isCancellable;
  final String journeyType;
  final DateTime? pickupAt;
  final String? pickupAddress;
  final String? dropoffAddress;
  final String? vehicle;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerNotes;
  final DateTime? createdAt;
  final DateTime? cancelledAt;
  final List<BookingLeg> legs;
  final List<FareItem> fareItems;
  final CancellationRequestSummary? cancellationRequest;

  bool get isReturn => journeyType == 'return';

  bool get isCancelled => status == 'cancelled' || cancelledAt != null;

  bool get isPaid => paymentStatus == 'paid';

  /// A journey that has not happened yet, which is what the "Upcoming" tab
  /// shows. A booking with no pickup time cannot be placed and is treated as
  /// upcoming so it is never hidden from the customer.
  bool get isUpcoming =>
      !isCancelled &&
      status != 'completed' &&
      (pickupAt == null || pickupAt!.isAfter(DateTime.now()));
}

DateTime? _parseDate(Object? value) =>
    value is String && value.isNotEmpty ? DateTime.tryParse(value)?.toLocal() : null;

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
