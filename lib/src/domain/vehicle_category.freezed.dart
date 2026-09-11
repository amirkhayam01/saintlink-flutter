// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VehicleCategory {

 String get slug; String get name; int get passengerCapacity; int get luggageCapacity; int get handLuggageCapacity; int get sortOrder;@JsonKey(name: 'shortDescription') String? get description;/// The server's own wording, e.g. "Up to 4 passengers, 2 large cases and
/// 2 hand luggage items" — preferred on screen over a number we assemble.
 String? get capacitySummary;/// Site-relative, e.g. `/images/vehicles/saloon-car-v1.webp`.
@JsonKey(name: 'image') String? get imagePath;
/// Create a copy of VehicleCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleCategoryCopyWith<VehicleCategory> get copyWith => _$VehicleCategoryCopyWithImpl<VehicleCategory>(this as VehicleCategory, _$identity);

  /// Serializes this VehicleCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VehicleCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleCategory&&(identical(other.slug, _this.slug) || other.slug == _this.slug)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.passengerCapacity, _this.passengerCapacity) || other.passengerCapacity == _this.passengerCapacity)&&(identical(other.luggageCapacity, _this.luggageCapacity) || other.luggageCapacity == _this.luggageCapacity)&&(identical(other.handLuggageCapacity, _this.handLuggageCapacity) || other.handLuggageCapacity == _this.handLuggageCapacity)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.capacitySummary, _this.capacitySummary) || other.capacitySummary == _this.capacitySummary)&&(identical(other.imagePath, _this.imagePath) || other.imagePath == _this.imagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VehicleCategory;
  return Object.hash(runtimeType,_this.slug,_this.name,_this.passengerCapacity,_this.luggageCapacity,_this.handLuggageCapacity,_this.sortOrder,_this.description,_this.capacitySummary,_this.imagePath);
}

@override
String toString() {
  final _this = this as VehicleCategory;
  return 'VehicleCategory(slug: ${_this.slug}, name: ${_this.name}, passengerCapacity: ${_this.passengerCapacity}, luggageCapacity: ${_this.luggageCapacity}, handLuggageCapacity: ${_this.handLuggageCapacity}, sortOrder: ${_this.sortOrder}, description: ${_this.description}, capacitySummary: ${_this.capacitySummary}, imagePath: ${_this.imagePath})';
}


}

/// @nodoc
abstract mixin class $VehicleCategoryCopyWith<$Res>  {
  factory $VehicleCategoryCopyWith(VehicleCategory value, $Res Function(VehicleCategory) _then) = _$VehicleCategoryCopyWithImpl;
@useResult
$Res call({
 String slug, String name, int passengerCapacity, int luggageCapacity, int handLuggageCapacity, int sortOrder,@JsonKey(name: 'shortDescription') String? description, String? capacitySummary,@JsonKey(name: 'image') String? imagePath
});




}
/// @nodoc
class _$VehicleCategoryCopyWithImpl<$Res>
    implements $VehicleCategoryCopyWith<$Res> {
  _$VehicleCategoryCopyWithImpl(this._self, this._then);

  final VehicleCategory _self;
  final $Res Function(VehicleCategory) _then;

/// Create a copy of VehicleCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,Object? passengerCapacity = null,Object? luggageCapacity = null,Object? handLuggageCapacity = null,Object? sortOrder = null,Object? description = freezed,Object? capacitySummary = freezed,Object? imagePath = freezed,}) {
  return _then(VehicleCategory(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,passengerCapacity: null == passengerCapacity ? _self.passengerCapacity : passengerCapacity // ignore: cast_nullable_to_non_nullable
as int,luggageCapacity: null == luggageCapacity ? _self.luggageCapacity : luggageCapacity // ignore: cast_nullable_to_non_nullable
as int,handLuggageCapacity: null == handLuggageCapacity ? _self.handLuggageCapacity : handLuggageCapacity // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,capacitySummary: freezed == capacitySummary ? _self.capacitySummary : capacitySummary // ignore: cast_nullable_to_non_nullable
as String?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleCategory].
extension VehicleCategoryPatterns on VehicleCategory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleCategory() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleCategory value)  $default,){
final _that = this;
switch (_that) {
case _VehicleCategory():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleCategory value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleCategory() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String slug,  String name,  int passengerCapacity,  int luggageCapacity,  int handLuggageCapacity,  int sortOrder, @JsonKey(name: 'shortDescription')  String? description,  String? capacitySummary, @JsonKey(name: 'image')  String? imagePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleCategory() when $default != null:
return $default(_that.slug,_that.name,_that.passengerCapacity,_that.luggageCapacity,_that.handLuggageCapacity,_that.sortOrder,_that.description,_that.capacitySummary,_that.imagePath);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String slug,  String name,  int passengerCapacity,  int luggageCapacity,  int handLuggageCapacity,  int sortOrder, @JsonKey(name: 'shortDescription')  String? description,  String? capacitySummary, @JsonKey(name: 'image')  String? imagePath)  $default,) {final _that = this;
switch (_that) {
case _VehicleCategory():
return $default(_that.slug,_that.name,_that.passengerCapacity,_that.luggageCapacity,_that.handLuggageCapacity,_that.sortOrder,_that.description,_that.capacitySummary,_that.imagePath);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String slug,  String name,  int passengerCapacity,  int luggageCapacity,  int handLuggageCapacity,  int sortOrder, @JsonKey(name: 'shortDescription')  String? description,  String? capacitySummary, @JsonKey(name: 'image')  String? imagePath)?  $default,) {final _that = this;
switch (_that) {
case _VehicleCategory() when $default != null:
return $default(_that.slug,_that.name,_that.passengerCapacity,_that.luggageCapacity,_that.handLuggageCapacity,_that.sortOrder,_that.description,_that.capacitySummary,_that.imagePath);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.none)
class _VehicleCategory extends VehicleCategory {
  const _VehicleCategory({required this.slug, required this.name, required this.passengerCapacity, required this.luggageCapacity, required this.handLuggageCapacity, required this.sortOrder, @JsonKey(name: 'shortDescription') this.description, this.capacitySummary, @JsonKey(name: 'image') this.imagePath}): super._();
  factory _VehicleCategory.fromJson(Map<String, dynamic> json) => _$VehicleCategoryFromJson(json);

@override final  String slug;
@override final  String name;
@override final  int passengerCapacity;
@override final  int luggageCapacity;
@override final  int handLuggageCapacity;
@override final  int sortOrder;
@override@JsonKey(name: 'shortDescription') final  String? description;
/// The server's own wording, e.g. "Up to 4 passengers, 2 large cases and
/// 2 hand luggage items" — preferred on screen over a number we assemble.
@override final  String? capacitySummary;
/// Site-relative, e.g. `/images/vehicles/saloon-car-v1.webp`.
@override@JsonKey(name: 'image') final  String? imagePath;

/// Create a copy of VehicleCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleCategoryCopyWith<_VehicleCategory> get copyWith => __$VehicleCategoryCopyWithImpl<_VehicleCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleCategory&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.passengerCapacity, passengerCapacity) || other.passengerCapacity == passengerCapacity)&&(identical(other.luggageCapacity, luggageCapacity) || other.luggageCapacity == luggageCapacity)&&(identical(other.handLuggageCapacity, handLuggageCapacity) || other.handLuggageCapacity == handLuggageCapacity)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.description, description) || other.description == description)&&(identical(other.capacitySummary, capacitySummary) || other.capacitySummary == capacitySummary)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,slug,name,passengerCapacity,luggageCapacity,handLuggageCapacity,sortOrder,description,capacitySummary,imagePath);
}

@override
String toString() {
    return 'VehicleCategory(slug: $slug, name: $name, passengerCapacity: $passengerCapacity, luggageCapacity: $luggageCapacity, handLuggageCapacity: $handLuggageCapacity, sortOrder: $sortOrder, description: $description, capacitySummary: $capacitySummary, imagePath: $imagePath)';
}


}

/// @nodoc
abstract mixin class _$VehicleCategoryCopyWith<$Res> implements $VehicleCategoryCopyWith<$Res> {
  factory _$VehicleCategoryCopyWith(_VehicleCategory value, $Res Function(_VehicleCategory) _then) = __$VehicleCategoryCopyWithImpl;
@override @useResult
$Res call({
 String slug, String name, int passengerCapacity, int luggageCapacity, int handLuggageCapacity, int sortOrder,@JsonKey(name: 'shortDescription') String? description, String? capacitySummary,@JsonKey(name: 'image') String? imagePath
});




}
/// @nodoc
class __$VehicleCategoryCopyWithImpl<$Res>
    implements _$VehicleCategoryCopyWith<$Res> {
  __$VehicleCategoryCopyWithImpl(this._self, this._then);

  final _VehicleCategory _self;
  final $Res Function(_VehicleCategory) _then;

/// Create a copy of VehicleCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,Object? passengerCapacity = null,Object? luggageCapacity = null,Object? handLuggageCapacity = null,Object? sortOrder = null,Object? description = freezed,Object? capacitySummary = freezed,Object? imagePath = freezed,}) {
  return _then(_VehicleCategory(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,passengerCapacity: null == passengerCapacity ? _self.passengerCapacity : passengerCapacity // ignore: cast_nullable_to_non_nullable
as int,luggageCapacity: null == luggageCapacity ? _self.luggageCapacity : luggageCapacity // ignore: cast_nullable_to_non_nullable
as int,handLuggageCapacity: null == handLuggageCapacity ? _self.handLuggageCapacity : handLuggageCapacity // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,capacitySummary: freezed == capacitySummary ? _self.capacitySummary : capacitySummary // ignore: cast_nullable_to_non_nullable
as String?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
