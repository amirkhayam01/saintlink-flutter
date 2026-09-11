import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/domain/place.dart';
import 'package:saints_link/src/domain/quote.dart';
import 'package:saints_link/src/features/booking/journey_draft.dart';

/*
 * The server fingerprints the journey fields when it prices a quote and refuses
 * a booking whose fields differ. These tests pin the payload shape: a change
 * here that passes silently would surface as "Journey details changed" for
 * every customer at the last step of checkout.
 */
void main() {
  final draft = JourneyDraft(
    pickup: const PlaceSelection(address: '  Southampton Central  Station ', placeId: 'p1', latitude: 50.9, longitude: -1.4),
    dropoff: const PlaceSelection(address: 'Heathrow Airport Terminal 5'),
    pickupDate: DateTime(2026, 9, 12),
    pickupTime: const TimeOfDay(hour: 9, minute: 5),
    passengerCount: 2,
    luggageCount: 1,
  );

  test('quote payload uses the server field names and formats', () {
    final payload = draft.toQuotePayload();

    expect(payload['pickup_address'], 'Southampton Central  Station');
    expect(payload['pickup_place_id'], 'p1');
    expect(payload['pickup_lat'], 50.9);
    expect(payload['dropoff_address'], 'Heathrow Airport Terminal 5');
    expect(payload.containsKey('dropoff_lat'), isFalse);
    expect(payload['pickup_date'], '2026-09-12');
    expect(payload['pickup_time'], '09:05');
    expect(payload['journey_type'], 'one_way');
    expect(payload.containsKey('return_date'), isFalse);
    expect(payload['passenger_count'], 2);
    expect(payload['luggage_count'], 1);
    expect(payload['via_addresses'], isEmpty);
  });

  test('booking payload carries every journey field unchanged plus the customer', () {
    final quote = draft.toQuotePayload();
    final booking = draft.toBookingPayload(
      quoteToken: 'tok',
      vehicleCategorySlug: 'saloon-car',
      customerName: ' Alex Rivers ',
      customerPhone: '07700 900123',
      customerEmail: 'Alex@Example.com',
    );

    for (final entry in quote.entries) {
      expect(booking[entry.key], entry.value, reason: entry.key);
    }
    expect(booking['quote_token'], 'tok');
    expect(booking['vehicle_category'], 'saloon-car');
    expect(booking['customer_name'], 'Alex Rivers');
    expect(booking['customer_email'], 'alex@example.com');
    expect(booking['terms_accepted'], isTrue);
    expect(booking.containsKey('special_instructions'), isFalse);
  });

  test('a return journey sends both legs and switching it off drops the dates', () {
    final withReturn = draft.copyWith(isReturn: true, returnDate: DateTime(2026, 9, 14), returnTime: const TimeOfDay(hour: 18, minute: 30));

    expect(withReturn.isQuotable, isTrue);
    expect(withReturn.toQuotePayload()['journey_type'], 'return');
    expect(withReturn.toQuotePayload()['return_date'], '2026-09-14');
    expect(withReturn.toQuotePayload()['return_time'], '18:30');

    final without = withReturn.withoutReturn();
    expect(without.returnDate, isNull);
    expect(without.toQuotePayload().containsKey('return_time'), isFalse);
  });

  test('is not quotable when the two ends are the same place or a return is incomplete', () {
    expect(draft.copyWith(dropoff: draft.pickup).isQuotable, isFalse);
    expect(draft.copyWith(isReturn: true).isQuotable, isFalse);
    expect(const JourneyDraft().isQuotable, isFalse);
  });

  test('quote parses fares keyed by vehicle slug and treats missing return as null', () {
    final quote = Quote.fromJson({
      'quote_token': 't',
      'expires_at': '2026-09-12T09:30:00+01:00',
      'fares': {
        'saloon-car': {'single': 125, 'return': 250.0},
        'minibus': {'single': 180.5, 'return': null},
      },
      'distance_miles': null,
      'estimated_duration_minutes': 95,
    });

    expect(quote.fareFor('saloon-car')!.single, 125.0);
    expect(quote.fareFor('saloon-car')!.returnTotal, 250.0);
    expect(quote.fareFor('minibus')!.returnTotal, isNull);
    expect(quote.isAvailable('executive'), isFalse);
    expect(quote.distanceMiles, isNull);
    expect(quote.estimatedDurationMinutes, 95);
  });
}
