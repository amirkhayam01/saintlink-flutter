import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_category.freezed.dart';
part 'vehicle_category.g.dart';

/// A vehicle class the business sells, with the limits the quote engine
/// enforces. Capacities are shown up front so a party of six is not offered a
/// saloon and then told it does not fit.
///
/// `/vehicle-categories` serialises in camelCase — it is the same array the
/// website's fleet pages render (`VehicleCatalogue::forPublicPages`), unlike
/// the rest of the API. `test/fixtures` pins the live shape: a capacity that
/// silently read as 0 once marked every vehicle "too small".
@freezed
abstract class VehicleCategory with _$VehicleCategory {
  const VehicleCategory._();

  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.none)
  const factory VehicleCategory({
    required String slug,
    required String name,
    required int passengerCapacity,
    required int luggageCapacity,
    required int handLuggageCapacity,
    required int sortOrder,
    @JsonKey(name: 'shortDescription') String? description,

    /// The server's own wording, e.g. "Up to 4 passengers, 2 large cases and
    /// 2 hand luggage items" — preferred on screen over a number we assemble.
    String? capacitySummary,

    /// Site-relative, e.g. `/images/vehicles/saloon-car-v1.webp`.
    @JsonKey(name: 'image') String? imagePath,
  }) = _VehicleCategory;

  factory VehicleCategory.fromJson(Map<String, dynamic> json) => _$VehicleCategoryFromJson(json);

  bool fits({required int passengers, required int luggage}) =>
      passengers <= passengerCapacity && luggage <= luggageCapacity;
}
