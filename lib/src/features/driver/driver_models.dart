enum TripStatus {
  upcoming,
  accepted,
  arrived,
  inProgress,
  completed,
  cancelled,
}

class DriverJob {
  const DriverJob({
    required this.id,
    required this.reference,
    required this.type, // 'Airport Transfer', 'City Ride', etc.
    required this.pickupTime,
    required this.pickupAddress,
    required this.pickupDetail,
    required this.destinationAddress,
    required this.destinationDetail,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengersCount,
    required this.luggageCount,
    required this.fare,
    required this.vehicleInfo,
    this.flightNumber,
    this.notes,
    this.status = TripStatus.upcoming,
  });

  final String id;
  final String reference;
  final String type;
  final String pickupTime;
  final String pickupAddress;
  final String pickupDetail;
  final String destinationAddress;
  final String destinationDetail;
  final String passengerName;
  final String passengerPhone;
  final int passengersCount;
  final int luggageCount;
  final double fare;
  final String vehicleInfo;
  final String? flightNumber;
  final String? notes;
  final TripStatus status;

  DriverJob copyWith({
    TripStatus? status,
  }) {
    return DriverJob(
      id: id,
      reference: reference,
      type: type,
      pickupTime: pickupTime,
      pickupAddress: pickupAddress,
      pickupDetail: pickupDetail,
      destinationAddress: destinationAddress,
      destinationDetail: destinationDetail,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      passengersCount: passengersCount,
      luggageCount: luggageCount,
      fare: fare,
      vehicleInfo: vehicleInfo,
      flightNumber: flightNumber,
      notes: notes,
      status: status ?? this.status,
    );
  }
}

class DriverMessage {
  const DriverMessage({
    required this.id,
    required this.sender,
    required this.snippet,
    required this.time,
    this.unread = false,
  });

  final String id;
  final String sender;
  final String snippet;
  final String time;
  final bool unread;
}
