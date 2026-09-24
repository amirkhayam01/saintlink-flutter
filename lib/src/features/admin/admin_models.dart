class AdminBooking {
  const AdminBooking({
    required this.id,
    required this.reference,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.pickupAddress,
    required this.pickupTime,
    required this.destinationAddress,
    required this.destinationTime,
    required this.vehicleCategory,
    required this.driverName,
    required this.status,
    required this.fare,
    required this.paymentMethod,
    required this.createdAt,
    this.flightNumber,
    this.isUnassigned = false,
  });

  final int id;
  final String reference;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String pickupAddress;
  final String pickupTime;
  final String destinationAddress;
  final String destinationTime;
  final String vehicleCategory;
  final String driverName;
  final String status; // 'Awaiting Payment', 'Cancelled', 'Completed', 'Confirmed'
  final double fare;
  final String paymentMethod;
  final String createdAt;
  final String? flightNumber;
  final bool isUnassigned;

  AdminBooking copyWith({
    String? driverName,
    String? status,
    bool? isUnassigned,
  }) {
    return AdminBooking(
      id: id,
      reference: reference,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      pickupAddress: pickupAddress,
      pickupTime: pickupTime,
      destinationAddress: destinationAddress,
      destinationTime: destinationTime,
      vehicleCategory: vehicleCategory,
      driverName: driverName ?? this.driverName,
      status: status ?? this.status,
      fare: fare,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
      flightNumber: flightNumber,
      isUnassigned: isUnassigned ?? this.isUnassigned,
    );
  }
}

class AdminDriver {
  const AdminDriver({
    required this.id,
    required this.name,
    required this.initials,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.status, // 'Available', 'On Trip', 'Offline'
    required this.rating,
    required this.tripsCount,
    required this.phone,
  });

  final int id;
  final String name;
  final String initials;
  final String vehicleName;
  final String vehiclePlate;
  final String status;
  final double rating;
  final int tripsCount;
  final String phone;
}

class AdminVehicle {
  const AdminVehicle({
    required this.name,
    required this.seats,
    required this.bags,
    required this.categoryType,
    required this.availableCount,
    required this.imagePath,
  });

  final String name;
  final int seats;
  final int bags;
  final String categoryType;
  final int availableCount;
  final String imagePath;
}

enum AlertCategory { all, urgent, confirmations, cancellations }

class AdminAlertItem {
  const AdminAlertItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.actionLabel,
  });

  final String id;
  final String title;
  final String subtitle;
  final AlertCategory category;
  final String actionLabel;
}
