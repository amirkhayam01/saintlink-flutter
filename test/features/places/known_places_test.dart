import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/features/places/known_places.dart';

void main() {
  test('every name the app uses for a place resolves to a located one', () {
    for (final name in [
      'London Heathrow Airport (LHR)',
      'Heathrow Airport',
      'Southampton Airport (SOU)',
      'Ocean Cruise Terminal, Southampton',
      'Ocean Cruise Terminal',
      'Queen Elizabeth II Cruise Terminal, Southampton',
      'Portsmouth International Port',
      'Southampton Central',
      'Central London',
      'Luton Airport',
    ]) {
      expect(KnownPlaces.resolve(name).isLocated, isTrue, reason: name);
    }
  });

  test('a name the app does not know is kept as typed, unlocated', () {
    final place = KnownPlaces.resolve('14 Bedford Place');
    expect(place.address, '14 Bedford Place');
    expect(place.isLocated, isFalse);
  });
}
