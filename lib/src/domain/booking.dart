import 'package:freezed_annotation/freezed_annotation.dart';

import 'json.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

/*
 * A booking as `ApiBookingPresenter` sends it. One model covers the list
 * summary and the detail; detail-only fields are nullable or empty.
 */

/// A stop on a journey leg.
@freezed
abstract class BookingStop with _$BookingStop {
  const factory BookingStop({
    required String type,
    required String address,
    double? latitude,
    double? longitude,
  }) = _BookingStop;

  factory BookingStop.fromJson(Map<String, dynamic> json) =>
      _$BookingStopFromJson(json);
}

/// The flight a leg is tied to, when there is one.
@freezed
abstract class BookingFlight with _$BookingFlight {
  const factory BookingFlight({
    required String number,
    String? terminal,
    String? status,
  }) = _BookingFlight;

  factory BookingFlight.fromJson(Map<String, dynamic> json) =>
      _$BookingFlightFromJson(json);
}

/// One movement: the outward journey, or the way back.
@freezed
abstract class BookingLeg with _$BookingLeg {
  const BookingLeg._();

  const factory BookingLeg({
    required int id,
    required String direction,
    required String status,
    required List<BookingStop> stops,
    required int passengerCount,
    required int largeLuggageCount,
    required int includedWaitingMinutes,
    required bool meetAndGreet,

    /// What the customer should be ready for. On a tracked airport pickup this
    /// moves with the flight, while [requestedPickupAt] is what they chose.
    @JsonKey(fromJson: localDateTimeOrNull) DateTime? pickupAt,
    @JsonKey(fromJson: localDateTimeOrNull) DateTime? requestedPickupAt,
    String? serviceType,
    String? vehicle,
    double? distanceMiles,
    int? estimatedDurationMinutes,
    BookingFlight? flight,
  }) = _BookingLeg;

  factory BookingLeg.fromJson(Map<String, dynamic> json) =>
      _$BookingLegFromJson(json);

  bool get isReturnLeg => direction == 'return';

  /// True when flight tracking has moved the pickup away from the time the
  /// customer originally asked for — worth pointing out on screen.
  bool get pickupWasAdjusted =>
      pickupAt != null &&
      requestedPickupAt != null &&
      pickupAt != requestedPickupAt;

  String get pickupAddress =>
      _stopOfType('pickup')?.address ?? stops.first.address;

  String get dropoffAddress =>
      _stopOfType('dropoff')?.address ?? stops.last.address;

  List<BookingStop> get viaStops =>
      stops.where((stop) => stop.type == 'via').toList();

  BookingStop? _stopOfType(String type) {
    for (final stop in stops) {
      if (stop.type == type) return stop;
    }

    return null;
  }
}

@freezed
abstract class FareItem with _$FareItem {
  const factory FareItem({required String label, required double amount}) =
      _FareItem;

  factory FareItem.fromJson(Map<String, dynamic> json) =>
      _$FareItemFromJson(json);
}

/// A cancellation the customer has asked for and the office has not yet ruled on.
@freezed
abstract class CancellationRequest with _$CancellationRequest {
  const factory CancellationRequest({
    required int id,
    required String status,
    required String scope,
    required String reason,
    required double recommendedRefundPercentage,
    String? legDirection,
    @JsonKey(fromJson: localDateTimeOrNull) DateTime? requestedAt,
  }) = _CancellationRequest;

  factory CancellationRequest.fromJson(Map<String, dynamic> json) =>
      _$CancellationRequestFromJson(json);
}

@freezed
abstract class Booking with _$Booking {
  const Booking._();

  const factory Booking({
    required String reference,
    required String status,
    required String statusLabel,
    required String paymentStatus,
    required String paymentStatusLabel,
    required double totalAmount,
    required String currency,
    required String journeyType,
    required bool canPay,
    required bool isCancellable,
    @JsonKey(fromJson: localDateTimeOrNull) DateTime? pickupAt,
    String? pickupAddress,
    String? dropoffAddress,
    String? vehicle,

    // Detail-only fields below.
    @JsonKey(fromJson: localDateTimeOrNull) DateTime? createdAt,
    @JsonKey(fromJson: localDateTimeOrNull) DateTime? cancelledAt,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerNotes,
    @Default([]) List<BookingLeg> legs,
    @Default([]) List<FareItem> fareItems,
    CancellationRequest? cancellationRequest,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);

  bool get isReturn => journeyType == 'return';

  bool get isCancelled => status == 'cancelled' || cancelledAt != null;

  bool get isPaid => paymentStatus == 'paid';

  /// No pickup time counts as upcoming, so a booking is never hidden.
  bool get isUpcoming =>
      !isCancelled &&
      status != 'completed' &&
      (pickupAt == null || pickupAt!.isAfter(DateTime.now()));
}
