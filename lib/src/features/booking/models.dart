import 'package:flutter/foundation.dart';

/// A vehicle class the business sells, with the limits the quote engine
/// enforces. Capacities are shown up front so a party of six is not offered a
/// saloon and then told it does not fit.
@immutable
class VehicleCategory {
  const VehicleCategory({
    required this.slug,
    required this.name,
    required this.passengerCapacity,
    required this.luggageCapacity,
    this.handLuggageCapacity = 0,
    this.sortOrder = 0,
    this.description,
    this.capacitySummary,
    this.imagePath,
  });

  /// `/vehicle-categories` serialises in camelCase — it is the same array the
  /// website's fleet pages render (`VehicleCatalogue::forPublicPages`), unlike
  /// the rest of the API. `test/fixtures` pins the live shape: a capacity that
  /// silently read as 0 once marked every vehicle "too small".
  factory VehicleCategory.fromJson(Map<String, dynamic> json) {
    return VehicleCategory(
      slug: json['slug'] as String,
      name: json['name'] as String,
      passengerCapacity: json['passengerCapacity'] as int,
      luggageCapacity: json['luggageCapacity'] as int,
      handLuggageCapacity: json['handLuggageCapacity'] as int,
      sortOrder: json['sortOrder'] as int,
      description: json['shortDescription'] as String?,
      capacitySummary: json['capacitySummary'] as String?,
      imagePath: json['image'] as String?,
    );
  }

  final String slug;
  final String name;
  final int passengerCapacity;
  final int luggageCapacity;
  final int handLuggageCapacity;
  final int sortOrder;
  final String? description;

  /// The server's own wording, e.g. "Up to 4 passengers, 2 large cases and
  /// 2 hand luggage items" — preferred on screen over a number we assemble.
  final String? capacitySummary;

  /// Site-relative, e.g. `/images/vehicles/saloon-car-v1.webp`.
  final String? imagePath;

  bool fits({required int passengers, required int luggage}) =>
      passengers <= passengerCapacity && luggage <= luggageCapacity;
}

/// One vehicle's price for the journey that was quoted.
@immutable
class Fare {
  const Fare({required this.single, this.returnTotal});

  final double single;

  /// The total for both legs, or null when the vehicle cannot serve the return.
  final double? returnTotal;
}

/// A priced journey, held on the server and good until it expires.
///
/// The token is what the booking is made against — the app never sends a price,
/// and could not make one stick if it did.
@immutable
class Quote {
  const Quote({
    required this.token,
    required this.expiresAt,
    required this.fares,
    this.distanceMiles,
    this.estimatedDurationMinutes,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    final fares = <String, Fare>{};

    // Only vehicles the engine could price are in `fares` — the server drops
    // unavailable options before responding.
    (json['fares'] as Map<String, dynamic>).forEach((slug, value) {
      final entry = value as Map<String, dynamic>;
      fares[slug] = Fare(
        single: (entry['single'] as num).toDouble(),
        returnTotal: (entry['return'] as num?)?.toDouble(),
      );
    });

    return Quote(
      token: json['quote_token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String).toLocal(),
      fares: fares,
      // Null rather than zero: a fixed-fare tour has a price but no measured
      // route, and "0.0 miles" beside it reads as a fault.
      distanceMiles: (json['distance_miles'] as num?)?.toDouble(),
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
    );
  }

  final String token;
  final DateTime expiresAt;
  final Map<String, Fare> fares;
  final double? distanceMiles;
  final int? estimatedDurationMinutes;

  bool get hasExpired => DateTime.now().isAfter(expiresAt);

  Duration get remaining => expiresAt.difference(DateTime.now());

  Fare? fareFor(String slug) => fares[slug];

  /// Only vehicles the engine could actually price are offered. An unpriceable
  /// one is left out entirely rather than shown without a number.
  bool isAvailable(String slug) => fares.containsKey(slug);
}

/// A suggestion from the address search.
@immutable
class PlaceSuggestion {
  const PlaceSuggestion({required this.placeId, required this.description});

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) => PlaceSuggestion(
        placeId: json['place_id'] as String,
        description: json['description'] as String,
      );

  final String placeId;
  final String description;
}

/// What the native payment sheet needs to take a card.
@immutable
class PaymentSheetDetails {
  const PaymentSheetDetails({
    required this.clientSecret,
    required this.publishableKey,
    required this.merchantName,
    required this.amount,
    required this.currency,
  });

  factory PaymentSheetDetails.fromJson(Map<String, dynamic> json) => PaymentSheetDetails(
        clientSecret: json['client_secret'] as String,
        publishableKey: json['publishable_key'] as String,
        merchantName: json['merchant_name'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String,
      );

  final String clientSecret;
  final String publishableKey;
  final String merchantName;
  final double amount;
  final String currency;
}
