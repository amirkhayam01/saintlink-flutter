import 'package:freezed_annotation/freezed_annotation.dart';

import 'json.dart';

part 'quote.freezed.dart';
part 'quote.g.dart';

/// One vehicle's price for the journey that was quoted.
@freezed
abstract class Fare with _$Fare {
  const factory Fare({
    required double single,

    /// The total for both legs, or null when the vehicle cannot serve the return.
    @JsonKey(name: 'return') double? returnTotal,
  }) = _Fare;

  factory Fare.fromJson(Map<String, dynamic> json) => _$FareFromJson(json);
}

/// A priced journey, held on the server against its token until it expires. The app never sends a price.
@freezed
abstract class Quote with _$Quote {
  const Quote._();

  const factory Quote({
    @JsonKey(name: 'quote_token') required String token,
    @JsonKey(fromJson: localDateTime) required DateTime expiresAt,
    required Map<String, Fare> fares,

    /// Null rather than zero: a fixed-fare tour has a price but no measured
    /// route, and "0.0 miles" beside it reads as a fault.
    double? distanceMiles,
    int? estimatedDurationMinutes,
  }) = _Quote;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);

  bool get hasExpired => DateTime.now().isAfter(expiresAt);

  Duration get remaining => expiresAt.difference(DateTime.now());

  Fare? fareFor(String slug) => fares[slug];

  bool isAvailable(String slug) => fares.containsKey(slug);
}
