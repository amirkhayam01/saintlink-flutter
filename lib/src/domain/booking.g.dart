// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingStop _$BookingStopFromJson(Map<String, dynamic> json) => _BookingStop(
  type: json['type'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$BookingStopToJson(_BookingStop instance) =>
    <String, dynamic>{
      'type': instance.type,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_BookingFlight _$BookingFlightFromJson(Map<String, dynamic> json) =>
    _BookingFlight(
      number: json['number'] as String,
      terminal: json['terminal'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$BookingFlightToJson(_BookingFlight instance) =>
    <String, dynamic>{
      'number': instance.number,
      'terminal': instance.terminal,
      'status': instance.status,
    };

_BookingLeg _$BookingLegFromJson(Map<String, dynamic> json) => _BookingLeg(
  id: (json['id'] as num).toInt(),
  direction: json['direction'] as String,
  status: json['status'] as String,
  stops: (json['stops'] as List<dynamic>)
      .map((e) => BookingStop.fromJson(e as Map<String, dynamic>))
      .toList(),
  passengerCount: (json['passenger_count'] as num).toInt(),
  largeLuggageCount: (json['large_luggage_count'] as num).toInt(),
  includedWaitingMinutes: (json['included_waiting_minutes'] as num).toInt(),
  meetAndGreet: json['meet_and_greet'] as bool,
  pickupAt: localDateTimeOrNull(json['pickup_at'] as String?),
  requestedPickupAt: localDateTimeOrNull(
    json['requested_pickup_at'] as String?,
  ),
  serviceType: json['service_type'] as String?,
  vehicle: json['vehicle'] as String?,
  distanceMiles: (json['distance_miles'] as num?)?.toDouble(),
  estimatedDurationMinutes: (json['estimated_duration_minutes'] as num?)
      ?.toInt(),
  flight: json['flight'] == null
      ? null
      : BookingFlight.fromJson(json['flight'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookingLegToJson(_BookingLeg instance) =>
    <String, dynamic>{
      'id': instance.id,
      'direction': instance.direction,
      'status': instance.status,
      'stops': instance.stops.map((e) => e.toJson()).toList(),
      'passenger_count': instance.passengerCount,
      'large_luggage_count': instance.largeLuggageCount,
      'included_waiting_minutes': instance.includedWaitingMinutes,
      'meet_and_greet': instance.meetAndGreet,
      'pickup_at': instance.pickupAt?.toIso8601String(),
      'requested_pickup_at': instance.requestedPickupAt?.toIso8601String(),
      'service_type': instance.serviceType,
      'vehicle': instance.vehicle,
      'distance_miles': instance.distanceMiles,
      'estimated_duration_minutes': instance.estimatedDurationMinutes,
      'flight': instance.flight?.toJson(),
    };

_FareItem _$FareItemFromJson(Map<String, dynamic> json) => _FareItem(
  label: json['label'] as String,
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$FareItemToJson(_FareItem instance) => <String, dynamic>{
  'label': instance.label,
  'amount': instance.amount,
};

_CancellationRequest _$CancellationRequestFromJson(Map<String, dynamic> json) =>
    _CancellationRequest(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String,
      scope: json['scope'] as String,
      reason: json['reason'] as String,
      recommendedRefundPercentage:
          (json['recommended_refund_percentage'] as num).toDouble(),
      legDirection: json['leg_direction'] as String?,
      requestedAt: localDateTimeOrNull(json['requested_at'] as String?),
    );

Map<String, dynamic> _$CancellationRequestToJson(
  _CancellationRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'scope': instance.scope,
  'reason': instance.reason,
  'recommended_refund_percentage': instance.recommendedRefundPercentage,
  'leg_direction': instance.legDirection,
  'requested_at': instance.requestedAt?.toIso8601String(),
};

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  reference: json['reference'] as String,
  status: json['status'] as String,
  statusLabel: json['status_label'] as String,
  paymentStatus: json['payment_status'] as String,
  paymentStatusLabel: json['payment_status_label'] as String,
  totalAmount: (json['total_amount'] as num).toDouble(),
  currency: json['currency'] as String,
  journeyType: json['journey_type'] as String,
  canPay: json['can_pay'] as bool,
  isCancellable: json['is_cancellable'] as bool,
  pickupAt: localDateTimeOrNull(json['pickup_at'] as String?),
  pickupAddress: json['pickup_address'] as String?,
  dropoffAddress: json['dropoff_address'] as String?,
  vehicle: json['vehicle'] as String?,
  createdAt: localDateTimeOrNull(json['created_at'] as String?),
  cancelledAt: localDateTimeOrNull(json['cancelled_at'] as String?),
  customerName: json['customer_name'] as String?,
  customerPhone: json['customer_phone'] as String?,
  customerEmail: json['customer_email'] as String?,
  customerNotes: json['customer_notes'] as String?,
  legs:
      (json['legs'] as List<dynamic>?)
          ?.map((e) => BookingLeg.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  fareItems:
      (json['fare_items'] as List<dynamic>?)
          ?.map((e) => FareItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  cancellationRequest: json['cancellation_request'] == null
      ? null
      : CancellationRequest.fromJson(
          json['cancellation_request'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'reference': instance.reference,
  'status': instance.status,
  'status_label': instance.statusLabel,
  'payment_status': instance.paymentStatus,
  'payment_status_label': instance.paymentStatusLabel,
  'total_amount': instance.totalAmount,
  'currency': instance.currency,
  'journey_type': instance.journeyType,
  'can_pay': instance.canPay,
  'is_cancellable': instance.isCancellable,
  'pickup_at': instance.pickupAt?.toIso8601String(),
  'pickup_address': instance.pickupAddress,
  'dropoff_address': instance.dropoffAddress,
  'vehicle': instance.vehicle,
  'created_at': instance.createdAt?.toIso8601String(),
  'cancelled_at': instance.cancelledAt?.toIso8601String(),
  'customer_name': instance.customerName,
  'customer_phone': instance.customerPhone,
  'customer_email': instance.customerEmail,
  'customer_notes': instance.customerNotes,
  'legs': instance.legs.map((e) => e.toJson()).toList(),
  'fare_items': instance.fareItems.map((e) => e.toJson()).toList(),
  'cancellation_request': instance.cancellationRequest?.toJson(),
};
