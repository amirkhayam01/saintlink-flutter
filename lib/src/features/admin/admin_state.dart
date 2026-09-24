import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_models.dart';

class AdminState {
  const AdminState({
    this.currentNavIndex = 0,
    this.fleetTabIndex = 0,
    this.selectedAlertFilter = AlertCategory.all,
    this.searchQuery = '',
    required this.bookings,
    required this.drivers,
    required this.vehicles,
    required this.alerts,
  });

  final int currentNavIndex;
  final int fleetTabIndex; // 0: Drivers, 1: Vehicles
  final AlertCategory selectedAlertFilter;
  final String searchQuery;
  final List<AdminBooking> bookings;
  final List<AdminDriver> drivers;
  final List<AdminVehicle> vehicles;
  final List<AdminAlertItem> alerts;

  AdminState copyWith({
    int? currentNavIndex,
    int? fleetTabIndex,
    AlertCategory? selectedAlertFilter,
    String? searchQuery,
    List<AdminBooking>? bookings,
    List<AdminDriver>? drivers,
    List<AdminVehicle>? vehicles,
    List<AdminAlertItem>? alerts,
  }) {
    return AdminState(
      currentNavIndex: currentNavIndex ?? this.currentNavIndex,
      fleetTabIndex: fleetTabIndex ?? this.fleetTabIndex,
      selectedAlertFilter: selectedAlertFilter ?? this.selectedAlertFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      bookings: bookings ?? this.bookings,
      drivers: drivers ?? this.drivers,
      vehicles: vehicles ?? this.vehicles,
      alerts: alerts ?? this.alerts,
    );
  }
}

class AdminController extends Notifier<AdminState> {
  @override
  AdminState build() {
    return AdminState(
      bookings: _initialBookings,
      drivers: _initialDrivers,
      vehicles: _initialVehicles,
      alerts: _initialAlerts,
    );
  }

  void setNavIndex(int index) {
    state = state.copyWith(currentNavIndex: index);
  }

  void setFleetTab(int tab) {
    state = state.copyWith(fleetTabIndex: tab);
  }

  void setAlertFilter(AlertCategory filter) {
    state = state.copyWith(selectedAlertFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void assignDriver(int bookingId, String driverName) {
    state = state.copyWith(
      bookings: state.bookings.map((b) {
        if (b.id == bookingId) {
          return b.copyWith(
            driverName: driverName,
            isUnassigned: false,
            status: 'Confirmed',
          );
        }
        return b;
      }).toList(),
    );
  }

  void cancelBooking(int bookingId) {
    state = state.copyWith(
      bookings: state.bookings.map((b) {
        if (b.id == bookingId) {
          return b.copyWith(status: 'Cancelled');
        }
        return b;
      }).toList(),
    );
  }
}

final adminControllerProvider =
    NotifierProvider<AdminController, AdminState>(AdminController.new);

const _initialBookings = [
  AdminBooking(
    id: 38,
    reference: 'SL00038',
    customerName: 'Christopher Mcdowall',
    customerPhone: '+353 877145536',
    customerEmail: 'christopher@example.com',
    pickupAddress: 'Southampton SO18 2NL, UK',
    pickupTime: '11:15 pm',
    destinationAddress: 'Herbert Walker Ave, Southampton SO15 1AG, UK',
    destinationTime: '11:45 pm',
    vehicleCategory: '8-Seater Minibus',
    driverName: 'Not assigned',
    status: 'Awaiting Payment',
    fare: 35.60,
    paymentMethod: 'Web-site',
    createdAt: '24 Sept 2026 11:15 pm',
    isUnassigned: true,
  ),
  AdminBooking(
    id: 37,
    reference: 'SL00037',
    customerName: 'talha khan',
    customerPhone: '+44 7911 123456',
    customerEmail: 'talha@example.com',
    pickupAddress: 'London Stansted Airport',
    pickupTime: '8:48 pm',
    destinationAddress: 'Heathrow Airport',
    destinationTime: '9:55 pm',
    vehicleCategory: 'Estate Car',
    driverName: 'talha khan',
    status: 'Cancelled',
    fare: 122.95,
    paymentMethod: 'Web-site',
    createdAt: '24 Sept 2026 8:48 pm',
    isUnassigned: false,
  ),
  AdminBooking(
    id: 35,
    reference: 'SL00035',
    customerName: 'Talha',
    customerPhone: '+44 7922 654321',
    customerEmail: 'talha2@example.com',
    pickupAddress: 'Ocean Cruise Terminal',
    pickupTime: '5:46 pm',
    destinationAddress: 'Southampton',
    destinationTime: '6:05 pm',
    vehicleCategory: 'Saloon Car',
    driverName: 'Talha',
    status: 'Cancelled',
    fare: 10.00,
    paymentMethod: 'Web-site',
    createdAt: '24 Sept 2026 5:46 pm',
    isUnassigned: false,
  ),
  AdminBooking(
    id: 33,
    reference: 'SL00033',
    customerName: 'Amir K',
    customerPhone: '+44 7700 900123',
    customerEmail: 'amir@example.com',
    pickupAddress: 'Bournemouth Airport',
    pickupTime: '2:43 am',
    destinationAddress: 'Southampton Terminals',
    destinationTime: '3:30 am',
    vehicleCategory: 'Executive Saloon',
    driverName: 'Arthur Pendelton',
    status: 'Cancelled',
    fare: 1029.72,
    paymentMethod: 'Web-site',
    createdAt: '24 Sept 2026 2:43 am',
    isUnassigned: false,
  ),
];

const _initialDrivers = [
  AdminDriver(
    id: 1,
    name: 'Christopher Mcdowall',
    initials: 'CM',
    vehicleName: '8-Seater Minibus',
    vehiclePlate: 'RO71 XYK',
    status: 'Available',
    rating: 4.8,
    tripsCount: 142,
    phone: '+353 877145536',
  ),
  AdminDriver(
    id: 2,
    name: 'talha khan',
    initials: 'TK',
    vehicleName: 'Estate Car',
    vehiclePlate: 'SO20 PLM',
    status: 'On Trip',
    rating: 4.6,
    tripsCount: 88,
    phone: '+44 7911 123456',
  ),
  AdminDriver(
    id: 3,
    name: 'Talha',
    initials: 'Ta',
    vehicleName: 'Saloon Car',
    vehiclePlate: 'GU23 BNN',
    status: 'Available',
    rating: 4.7,
    tripsCount: 204,
    phone: '+44 7922 654321',
  ),
];

const _initialVehicles = [
  AdminVehicle(
    name: '8-Seater Minibus',
    seats: 8,
    bags: 8,
    categoryType: 'Minibus',
    availableCount: 3,
    imagePath: 'assets/vehicles/minibus-8-v1.webp',
  ),
  AdminVehicle(
    name: 'Estate Car',
    seats: 4,
    bags: 4,
    categoryType: 'Estate',
    availableCount: 2,
    imagePath: 'assets/vehicles/estate-car-v1.webp',
  ),
  AdminVehicle(
    name: 'Saloon Car',
    seats: 4,
    bags: 2,
    categoryType: 'Saloon',
    availableCount: 4,
    imagePath: 'assets/vehicles/saloon-car-v1.webp',
  ),
  AdminVehicle(
    name: 'Executive Saloon',
    seats: 3,
    bags: 3,
    categoryType: 'Executive',
    availableCount: 2,
    imagePath: 'assets/vehicles/executive-saloon-v1.webp',
  ),
  AdminVehicle(
    name: '6-Seater MPV',
    seats: 6,
    bags: 4,
    categoryType: 'MPV',
    availableCount: 1,
    imagePath: 'assets/vehicles/mpv-6-v1.webp',
  ),
];

const _initialAlerts = [
  AdminAlertItem(
    id: 'a1',
    title: '23 Unassigned Journeys',
    subtitle: 'No driver assigned for 23 journeys. Longest wait: 10 minutes',
    category: AlertCategory.urgent,
    actionLabel: 'View',
  ),
  AdminAlertItem(
    id: 'a2',
    title: '21 Awaiting Confirmation',
    subtitle: 'Bookings waiting for customer confirmation. Since 10:26 AM',
    category: AlertCategory.confirmations,
    actionLabel: 'View',
  ),
  AdminAlertItem(
    id: 'a3',
    title: '3 Cancellations',
    subtitle: '3 bookings were cancelled today. Last cancellation: 8:48 PM',
    category: AlertCategory.cancellations,
    actionLabel: 'View',
  ),
  AdminAlertItem(
    id: 'a4',
    title: '1 New Notification',
    subtitle: 'Driver has accepted a booking. SL00034 • 2:40 PM',
    category: AlertCategory.urgent,
    actionLabel: 'View',
  ),
  AdminAlertItem(
    id: 'a5',
    title: 'System Update',
    subtitle: 'Core dispatch rules updated successfully',
    category: AlertCategory.all,
    actionLabel: 'View',
  ),
];
