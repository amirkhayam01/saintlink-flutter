import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/booking.dart';
import '../../domain/customer.dart';

/// An in-memory preview account. It never creates or stores an API token.
class DemoSessionController extends Notifier<Customer?> {
  @override
  Customer? build() => null;

  Customer get customer => state!;

  Customer start() {
    if (!kDebugMode) throw StateError('Demo login requires a debug build.');
    const customer = Customer(
      id: 0,
      name: 'Alex Morgan',
      firstName: 'Alex',
      lastName: 'Morgan',
      email: 'alex@example.com',
      phone: '+447700900123',
      maskedPhone: '+44 7700 ***123',
      marketingConsent: false,
    );
    state = customer;
    return customer;
  }

  void update(Customer customer) => state = customer;
  void end() => state = null;
}

final demoSessionProvider = NotifierProvider<DemoSessionController, Customer?>(
  DemoSessionController.new,
);

List<Booking> demoTrips() {
  final now = DateTime.now();
  return [
    for (final days in [3, 8, -7])
      Booking(
        reference: 'DEMO-${days.abs()}',
        status: days > 0 ? 'confirmed' : 'completed',
        statusLabel: days > 0 ? 'Confirmed' : 'Completed',
        paymentStatus: 'paid',
        paymentStatusLabel: 'Paid',
        totalAmount: 115,
        currency: 'GBP',
        journeyType: 'one_way',
        canPay: false,
        isCancellable: false,
        pickupAt: now.add(Duration(days: days)),
        createdAt: now.subtract(const Duration(days: 10)),
        pickupAddress: 'Southampton Central Station',
        dropoffAddress: 'Heathrow Airport Terminal 5',
        vehicle: 'Saloon Car',
        customerName: 'Alex Morgan',
        customerPhone: '+447700900123',
        customerEmail: 'alex@example.com',
        fareItems: const [FareItem(label: 'Fixed fare', amount: 115)],
        legs: [
          BookingLeg(
            id: days.abs(),
            direction: 'outbound',
            status: days > 0 ? 'confirmed' : 'completed',
            stops: const [
              BookingStop(
                type: 'pickup',
                address: 'Southampton Central Station',
              ),
              BookingStop(
                type: 'dropoff',
                address: 'Heathrow Airport Terminal 5',
              ),
            ],
            passengerCount: 2,
            largeLuggageCount: 2,
            includedWaitingMinutes: 15,
            meetAndGreet: true,
            pickupAt: now.add(Duration(days: days)),
            vehicle: 'Saloon Car',
          ),
        ],
      ),
  ];
}
