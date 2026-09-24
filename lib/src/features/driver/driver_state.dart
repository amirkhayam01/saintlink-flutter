import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'driver_models.dart';

class DriverState {
  const DriverState({
    this.isOnline = true,
    this.currentNavIndex = 0,
    this.bookingsFilterIndex = 0,
    this.tripProgressStep = 0, // 0: On the way, 1: Arrived, 2: On Trip, 3: Completed
    required this.activeJob,
    required this.upcomingJobs,
    required this.messages,
  });

  final bool isOnline;
  final int currentNavIndex;
  final int bookingsFilterIndex;
  final int tripProgressStep;
  final DriverJob activeJob;
  final List<DriverJob> upcomingJobs;
  final List<DriverMessage> messages;

  DriverState copyWith({
    bool? isOnline,
    int? currentNavIndex,
    int? bookingsFilterIndex,
    int? tripProgressStep,
    DriverJob? activeJob,
    List<DriverJob>? upcomingJobs,
    List<DriverMessage>? messages,
  }) {
    return DriverState(
      isOnline: isOnline ?? this.isOnline,
      currentNavIndex: currentNavIndex ?? this.currentNavIndex,
      bookingsFilterIndex: bookingsFilterIndex ?? this.bookingsFilterIndex,
      tripProgressStep: tripProgressStep ?? this.tripProgressStep,
      activeJob: activeJob ?? this.activeJob,
      upcomingJobs: upcomingJobs ?? this.upcomingJobs,
      messages: messages ?? this.messages,
    );
  }
}

class DriverController extends Notifier<DriverState> {
  @override
  DriverState build() {
    return DriverState(
      activeJob: _initialActiveJob,
      upcomingJobs: _initialJobs,
      messages: _initialMessages,
    );
  }

  void toggleOnline(bool val) {
    state = state.copyWith(isOnline: val);
  }

  void setNavIndex(int index) {
    state = state.copyWith(currentNavIndex: index);
  }

  void setBookingsFilter(int index) {
    state = state.copyWith(bookingsFilterIndex: index);
  }

  void advanceTripStep() {
    final next = (state.tripProgressStep + 1).clamp(0, 3);
    state = state.copyWith(tripProgressStep: next);
  }

  void resetTrip() {
    state = state.copyWith(tripProgressStep: 0);
  }
}

final driverControllerProvider =
    NotifierProvider<DriverController, DriverState>(DriverController.new);

const _initialActiveJob = DriverJob(
  id: 'job-1',
  reference: 'SL-7842',
  type: 'Airport Transfer',
  pickupTime: 'Today • 4:30 PM',
  pickupAddress: 'Southampton Central Station',
  pickupDetail: 'Platform 1, Station Approach, Southampton SO14 0PQ',
  destinationAddress: 'Southampton Airport (SOU)',
  destinationDetail: 'Airport Rd, Southampton SO18 2TR',
  passengerName: 'Sarah Johnson',
  passengerPhone: '+44 7123 456789',
  passengersCount: 2,
  luggageCount: 2,
  fare: 24.50,
  vehicleInfo: 'Toyota Corolla • ABC 123',
  flightNumber: 'BA215 • 6:15 PM',
  notes: 'Meet at main entrance. Luggage: 2 bags.',
);

const _initialJobs = [
  DriverJob(
    id: 'job-1',
    reference: 'SL-7842',
    type: 'Airport Transfer',
    pickupTime: 'Today • 4:30 PM',
    pickupAddress: 'Southampton Central Station',
    pickupDetail: 'Platform 1, Station Approach, Southampton SO14 0PQ',
    destinationAddress: 'Southampton Airport (SOU)',
    destinationDetail: 'Airport Rd, Southampton SO18 2TR',
    passengerName: 'Sarah Johnson',
    passengerPhone: '+44 7123 456789',
    passengersCount: 2,
    luggageCount: 2,
    fare: 24.50,
    vehicleInfo: 'Toyota Corolla • ABC 123',
    flightNumber: 'BA215 • 6:15 PM',
    notes: 'Meet at main entrance. Luggage: 2 bags.',
    status: TripStatus.upcoming,
  ),
  DriverJob(
    id: 'job-2',
    reference: 'SL-7843',
    type: 'City Ride',
    pickupTime: 'Today • 6:15 PM',
    pickupAddress: 'Southampton Central Station',
    pickupDetail: 'Main Forecourt, Commercial Road',
    destinationAddress: 'Ocean Village',
    destinationDetail: 'Marina Way, Southampton SO14 3TL',
    passengerName: 'Mark Thompson',
    passengerPhone: '+44 7890 123456',
    passengersCount: 1,
    luggageCount: 1,
    fare: 15.00,
    vehicleInfo: 'Toyota Corolla • ABC 123',
    notes: 'Outside station cafe',
    status: TripStatus.upcoming,
  ),
  DriverJob(
    id: 'job-3',
    reference: 'SL-7844',
    type: 'Airport Transfer',
    pickupTime: 'Tomorrow • 9:20 AM',
    pickupAddress: 'Southampton Airport (SOU)',
    pickupDetail: 'Arrivals terminal pickup bay 2',
    destinationAddress: 'London Gatwick (LGW)',
    destinationDetail: 'North Terminal Drop-off',
    passengerName: 'Lord Harrison',
    passengerPhone: '+44 7722 334455',
    passengersCount: 3,
    luggageCount: 4,
    fare: 145.00,
    vehicleInfo: 'Toyota Corolla • ABC 123',
    flightNumber: 'EZY824',
    notes: 'Flight landing at 09:10 AM',
    status: TripStatus.upcoming,
  ),
];

const _initialMessages = [
  DriverMessage(
    id: 'm1',
    sender: 'Support Team',
    snippet: 'Your weekly payout of £320.00 has been processed.',
    time: '10:24 AM',
    unread: true,
  ),
  DriverMessage(
    id: 'm2',
    sender: 'Saints Link',
    snippet: 'New airport transfer bookings available in Southampton.',
    time: 'Yesterday',
  ),
  DriverMessage(
    id: 'm3',
    sender: 'Sarah Johnson',
    snippet: 'Thank you! I am waiting near Platform 1 exit.',
    time: 'Yesterday',
  ),
  DriverMessage(
    id: 'm4',
    sender: 'System',
    snippet: 'Your vehicle inspection certificate is verified.',
    time: '12 Sep',
  ),
  DriverMessage(
    id: 'm5',
    sender: 'Driver Support',
    snippet: 'Need any help? Dispatch is available 24/7.',
    time: '10 Sep',
  ),
];
