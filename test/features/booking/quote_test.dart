import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/domain/quote.dart';

import '../../fixtures/fixtures.dart';

void main() {
  final quote = Quote.fromJson(loadFixture('quote'));

  test('parses the live /quotes response', () {
    expect(quote.token, 'ad23a4f2-c4e1-4e00-b861-7dac80234b47');
    expect(quote.expiresAt.isUtc, isFalse);
    expect(quote.distanceMiles, 68.9);
    expect(quote.estimatedDurationMinutes, 117);
    expect(quote.fares.keys, [
      'saloon-car',
      'estate-car',
      'executive-saloon',
      'mpv-6',
      'minibus-8',
    ]);
  });

  test(
    'whole-number fares arrive as JSON integers and are read as doubles',
    () {
      final saloon = quote.fareFor('saloon-car')!;

      expect(saloon.single, 125.0);
      expect(saloon.returnTotal, 250.0);
    },
  );

  test('a vehicle the engine could not price is not available', () {
    expect(quote.isAvailable('minibus-8'), isTrue);
    expect(quote.isAvailable('coach'), isFalse);
    expect(quote.fareFor('coach'), isNull);
  });
}
