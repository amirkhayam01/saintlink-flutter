import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/domain/vehicle_category.dart';

import '../../fixtures/fixtures.dart';

void main() {
  final data = loadFixture('vehicle_categories')['data'] as List<dynamic>;
  final vehicles = data.map((item) => VehicleCategory.fromJson(item as Map<String, dynamic>)).toList();

  test('parses the live camelCase response with real capacities', () {
    final saloon = vehicles.firstWhere((v) => v.slug == 'saloon-car');

    expect(saloon.name, 'Saloon Car');
    expect(saloon.passengerCapacity, 4);
    expect(saloon.luggageCapacity, 2);
    expect(saloon.handLuggageCapacity, 2);
    expect(saloon.sortOrder, 10);
    expect(saloon.capacitySummary, contains('Up to 4 passengers'));
    expect(saloon.imagePath, startsWith('/images/vehicles/'));
  });

  test('no live vehicle parses with a zero capacity', () {
    // Zero capacity means fits() is always false: the customer could get a
    // price but never choose a vehicle.
    for (final vehicle in vehicles) {
      expect(vehicle.passengerCapacity, greaterThan(0), reason: vehicle.slug);
      expect(vehicle.luggageCapacity, greaterThan(0), reason: vehicle.slug);
    }
  });

  test('fits() respects both limits', () {
    final minibus = vehicles.firstWhere((v) => v.slug == 'minibus-8');

    expect(minibus.fits(passengers: 8, luggage: minibus.luggageCapacity), isTrue);
    expect(minibus.fits(passengers: 9, luggage: 0), isFalse);
    expect(minibus.fits(passengers: 1, luggage: minibus.luggageCapacity + 1), isFalse);
  });
}
