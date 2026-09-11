// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingStop {

 String get type; String get address; double? get latitude; double? get longitude;
/// Create a copy of BookingStop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingStopCopyWith<BookingStop> get copyWith => _$BookingStopCopyWithImpl<BookingStop>(this as BookingStop, _$identity);

  /// Serializes this BookingStop to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BookingStop;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingStop&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BookingStop;
  return Object.hash(runtimeType,_this.type,_this.address,_this.latitude,_this.longitude);
}

@override
String toString() {
  final _this = this as BookingStop;
  return 'BookingStop(type: ${_this.type}, address: ${_this.address}, latitude: ${_this.latitude}, longitude: ${_this.longitude})';
}


}

/// @nodoc
abstract mixin class $BookingStopCopyWith<$Res>  {
  factory $BookingStopCopyWith(BookingStop value, $Res Function(BookingStop) _then) = _$BookingStopCopyWithImpl;
@useResult
$Res call({
 String type, String address, double? latitude, double? longitude
});




}
/// @nodoc
class _$BookingStopCopyWithImpl<$Res>
    implements $BookingStopCopyWith<$Res> {
  _$BookingStopCopyWithImpl(this._self, this._then);

  final BookingStop _self;
  final $Res Function(BookingStop) _then;

/// Create a copy of BookingStop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? address = null,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(BookingStop(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingStop].
extension BookingStopPatterns on BookingStop {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingStop value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingStop() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingStop value)  $default,){
final _that = this;
switch (_that) {
case _BookingStop():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingStop value)?  $default,){
final _that = this;
switch (_that) {
case _BookingStop() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String address,  double? latitude,  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingStop() when $default != null:
return $default(_that.type,_that.address,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String address,  double? latitude,  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _BookingStop():
return $default(_that.type,_that.address,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String address,  double? latitude,  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _BookingStop() when $default != null:
return $default(_that.type,_that.address,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingStop implements BookingStop {
  const _BookingStop({required this.type, required this.address, this.latitude, this.longitude});
  factory _BookingStop.fromJson(Map<String, dynamic> json) => _$BookingStopFromJson(json);

@override final  String type;
@override final  String address;
@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of BookingStop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingStopCopyWith<_BookingStop> get copyWith => __$BookingStopCopyWithImpl<_BookingStop>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingStopToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingStop&&(identical(other.type, type) || other.type == type)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,address,latitude,longitude);
}

@override
String toString() {
    return 'BookingStop(type: $type, address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$BookingStopCopyWith<$Res> implements $BookingStopCopyWith<$Res> {
  factory _$BookingStopCopyWith(_BookingStop value, $Res Function(_BookingStop) _then) = __$BookingStopCopyWithImpl;
@override @useResult
$Res call({
 String type, String address, double? latitude, double? longitude
});




}
/// @nodoc
class __$BookingStopCopyWithImpl<$Res>
    implements _$BookingStopCopyWith<$Res> {
  __$BookingStopCopyWithImpl(this._self, this._then);

  final _BookingStop _self;
  final $Res Function(_BookingStop) _then;

/// Create a copy of BookingStop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? address = null,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_BookingStop(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$BookingFlight {

 String get number; String? get terminal; String? get status;
/// Create a copy of BookingFlight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingFlightCopyWith<BookingFlight> get copyWith => _$BookingFlightCopyWithImpl<BookingFlight>(this as BookingFlight, _$identity);

  /// Serializes this BookingFlight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BookingFlight;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingFlight&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.terminal, _this.terminal) || other.terminal == _this.terminal)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BookingFlight;
  return Object.hash(runtimeType,_this.number,_this.terminal,_this.status);
}

@override
String toString() {
  final _this = this as BookingFlight;
  return 'BookingFlight(number: ${_this.number}, terminal: ${_this.terminal}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $BookingFlightCopyWith<$Res>  {
  factory $BookingFlightCopyWith(BookingFlight value, $Res Function(BookingFlight) _then) = _$BookingFlightCopyWithImpl;
@useResult
$Res call({
 String number, String? terminal, String? status
});




}
/// @nodoc
class _$BookingFlightCopyWithImpl<$Res>
    implements $BookingFlightCopyWith<$Res> {
  _$BookingFlightCopyWithImpl(this._self, this._then);

  final BookingFlight _self;
  final $Res Function(BookingFlight) _then;

/// Create a copy of BookingFlight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? terminal = freezed,Object? status = freezed,}) {
  return _then(BookingFlight(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,terminal: freezed == terminal ? _self.terminal : terminal // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingFlight].
extension BookingFlightPatterns on BookingFlight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingFlight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingFlight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingFlight value)  $default,){
final _that = this;
switch (_that) {
case _BookingFlight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingFlight value)?  $default,){
final _that = this;
switch (_that) {
case _BookingFlight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String number,  String? terminal,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingFlight() when $default != null:
return $default(_that.number,_that.terminal,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String number,  String? terminal,  String? status)  $default,) {final _that = this;
switch (_that) {
case _BookingFlight():
return $default(_that.number,_that.terminal,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String number,  String? terminal,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _BookingFlight() when $default != null:
return $default(_that.number,_that.terminal,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingFlight implements BookingFlight {
  const _BookingFlight({required this.number, this.terminal, this.status});
  factory _BookingFlight.fromJson(Map<String, dynamic> json) => _$BookingFlightFromJson(json);

@override final  String number;
@override final  String? terminal;
@override final  String? status;

/// Create a copy of BookingFlight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingFlightCopyWith<_BookingFlight> get copyWith => __$BookingFlightCopyWithImpl<_BookingFlight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingFlightToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingFlight&&(identical(other.number, number) || other.number == number)&&(identical(other.terminal, terminal) || other.terminal == terminal)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,number,terminal,status);
}

@override
String toString() {
    return 'BookingFlight(number: $number, terminal: $terminal, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BookingFlightCopyWith<$Res> implements $BookingFlightCopyWith<$Res> {
  factory _$BookingFlightCopyWith(_BookingFlight value, $Res Function(_BookingFlight) _then) = __$BookingFlightCopyWithImpl;
@override @useResult
$Res call({
 String number, String? terminal, String? status
});




}
/// @nodoc
class __$BookingFlightCopyWithImpl<$Res>
    implements _$BookingFlightCopyWith<$Res> {
  __$BookingFlightCopyWithImpl(this._self, this._then);

  final _BookingFlight _self;
  final $Res Function(_BookingFlight) _then;

/// Create a copy of BookingFlight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? terminal = freezed,Object? status = freezed,}) {
  return _then(_BookingFlight(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,terminal: freezed == terminal ? _self.terminal : terminal // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BookingLeg {

 int get id; String get direction; String get status; List<BookingStop> get stops; int get passengerCount; int get largeLuggageCount; int get includedWaitingMinutes; bool get meetAndGreet;/// What the customer should be ready for. On a tracked airport pickup this
/// moves with the flight, while [requestedPickupAt] is what they chose.
@JsonKey(fromJson: localDateTimeOrNull) DateTime? get pickupAt;@JsonKey(fromJson: localDateTimeOrNull) DateTime? get requestedPickupAt; String? get serviceType; String? get vehicle; double? get distanceMiles; int? get estimatedDurationMinutes; BookingFlight? get flight;
/// Create a copy of BookingLeg
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingLegCopyWith<BookingLeg> get copyWith => _$BookingLegCopyWithImpl<BookingLeg>(this as BookingLeg, _$identity);

  /// Serializes this BookingLeg to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BookingLeg;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingLeg&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.stops, _this.stops)&&(identical(other.passengerCount, _this.passengerCount) || other.passengerCount == _this.passengerCount)&&(identical(other.largeLuggageCount, _this.largeLuggageCount) || other.largeLuggageCount == _this.largeLuggageCount)&&(identical(other.includedWaitingMinutes, _this.includedWaitingMinutes) || other.includedWaitingMinutes == _this.includedWaitingMinutes)&&(identical(other.meetAndGreet, _this.meetAndGreet) || other.meetAndGreet == _this.meetAndGreet)&&(identical(other.pickupAt, _this.pickupAt) || other.pickupAt == _this.pickupAt)&&(identical(other.requestedPickupAt, _this.requestedPickupAt) || other.requestedPickupAt == _this.requestedPickupAt)&&(identical(other.serviceType, _this.serviceType) || other.serviceType == _this.serviceType)&&(identical(other.vehicle, _this.vehicle) || other.vehicle == _this.vehicle)&&(identical(other.distanceMiles, _this.distanceMiles) || other.distanceMiles == _this.distanceMiles)&&(identical(other.estimatedDurationMinutes, _this.estimatedDurationMinutes) || other.estimatedDurationMinutes == _this.estimatedDurationMinutes)&&(identical(other.flight, _this.flight) || other.flight == _this.flight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BookingLeg;
  return Object.hash(runtimeType,_this.id,_this.direction,_this.status,const DeepCollectionEquality().hash(_this.stops),_this.passengerCount,_this.largeLuggageCount,_this.includedWaitingMinutes,_this.meetAndGreet,_this.pickupAt,_this.requestedPickupAt,_this.serviceType,_this.vehicle,_this.distanceMiles,_this.estimatedDurationMinutes,_this.flight);
}

@override
String toString() {
  final _this = this as BookingLeg;
  return 'BookingLeg(id: ${_this.id}, direction: ${_this.direction}, status: ${_this.status}, stops: ${_this.stops}, passengerCount: ${_this.passengerCount}, largeLuggageCount: ${_this.largeLuggageCount}, includedWaitingMinutes: ${_this.includedWaitingMinutes}, meetAndGreet: ${_this.meetAndGreet}, pickupAt: ${_this.pickupAt}, requestedPickupAt: ${_this.requestedPickupAt}, serviceType: ${_this.serviceType}, vehicle: ${_this.vehicle}, distanceMiles: ${_this.distanceMiles}, estimatedDurationMinutes: ${_this.estimatedDurationMinutes}, flight: ${_this.flight})';
}


}

/// @nodoc
abstract mixin class $BookingLegCopyWith<$Res>  {
  factory $BookingLegCopyWith(BookingLeg value, $Res Function(BookingLeg) _then) = _$BookingLegCopyWithImpl;
@useResult
$Res call({
 int id, String direction, String status, List<BookingStop> stops, int passengerCount, int largeLuggageCount, int includedWaitingMinutes, bool meetAndGreet,@JsonKey(fromJson: localDateTimeOrNull) DateTime? pickupAt,@JsonKey(fromJson: localDateTimeOrNull) DateTime? requestedPickupAt, String? serviceType, String? vehicle, double? distanceMiles, int? estimatedDurationMinutes, BookingFlight? flight
});


$BookingFlightCopyWith<$Res>? get flight;

}
/// @nodoc
class _$BookingLegCopyWithImpl<$Res>
    implements $BookingLegCopyWith<$Res> {
  _$BookingLegCopyWithImpl(this._self, this._then);

  final BookingLeg _self;
  final $Res Function(BookingLeg) _then;

/// Create a copy of BookingLeg
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? direction = null,Object? status = null,Object? stops = null,Object? passengerCount = null,Object? largeLuggageCount = null,Object? includedWaitingMinutes = null,Object? meetAndGreet = null,Object? pickupAt = freezed,Object? requestedPickupAt = freezed,Object? serviceType = freezed,Object? vehicle = freezed,Object? distanceMiles = freezed,Object? estimatedDurationMinutes = freezed,Object? flight = freezed,}) {
  return _then(BookingLeg(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,stops: null == stops ? _self.stops : stops // ignore: cast_nullable_to_non_nullable
as List<BookingStop>,passengerCount: null == passengerCount ? _self.passengerCount : passengerCount // ignore: cast_nullable_to_non_nullable
as int,largeLuggageCount: null == largeLuggageCount ? _self.largeLuggageCount : largeLuggageCount // ignore: cast_nullable_to_non_nullable
as int,includedWaitingMinutes: null == includedWaitingMinutes ? _self.includedWaitingMinutes : includedWaitingMinutes // ignore: cast_nullable_to_non_nullable
as int,meetAndGreet: null == meetAndGreet ? _self.meetAndGreet : meetAndGreet // ignore: cast_nullable_to_non_nullable
as bool,pickupAt: freezed == pickupAt ? _self.pickupAt : pickupAt // ignore: cast_nullable_to_non_nullable
as DateTime?,requestedPickupAt: freezed == requestedPickupAt ? _self.requestedPickupAt : requestedPickupAt // ignore: cast_nullable_to_non_nullable
as DateTime?,serviceType: freezed == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String?,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as String?,distanceMiles: freezed == distanceMiles ? _self.distanceMiles : distanceMiles // ignore: cast_nullable_to_non_nullable
as double?,estimatedDurationMinutes: freezed == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,flight: freezed == flight ? _self.flight : flight // ignore: cast_nullable_to_non_nullable
as BookingFlight?,
  ));
}
/// Create a copy of BookingLeg
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingFlightCopyWith<$Res>? get flight {
    if (_self.flight == null) {
    return null;
  }

  return $BookingFlightCopyWith<$Res>(_self.flight!, (value) {
    return _then(_self.copyWith(flight: value));
  });
}
}


/// Adds pattern-matching-related methods to [BookingLeg].
extension BookingLegPatterns on BookingLeg {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingLeg value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingLeg() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingLeg value)  $default,){
final _that = this;
switch (_that) {
case _BookingLeg():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingLeg value)?  $default,){
final _that = this;
switch (_that) {
case _BookingLeg() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String direction,  String status,  List<BookingStop> stops,  int passengerCount,  int largeLuggageCount,  int includedWaitingMinutes,  bool meetAndGreet, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? pickupAt, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? requestedPickupAt,  String? serviceType,  String? vehicle,  double? distanceMiles,  int? estimatedDurationMinutes,  BookingFlight? flight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingLeg() when $default != null:
return $default(_that.id,_that.direction,_that.status,_that.stops,_that.passengerCount,_that.largeLuggageCount,_that.includedWaitingMinutes,_that.meetAndGreet,_that.pickupAt,_that.requestedPickupAt,_that.serviceType,_that.vehicle,_that.distanceMiles,_that.estimatedDurationMinutes,_that.flight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String direction,  String status,  List<BookingStop> stops,  int passengerCount,  int largeLuggageCount,  int includedWaitingMinutes,  bool meetAndGreet, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? pickupAt, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? requestedPickupAt,  String? serviceType,  String? vehicle,  double? distanceMiles,  int? estimatedDurationMinutes,  BookingFlight? flight)  $default,) {final _that = this;
switch (_that) {
case _BookingLeg():
return $default(_that.id,_that.direction,_that.status,_that.stops,_that.passengerCount,_that.largeLuggageCount,_that.includedWaitingMinutes,_that.meetAndGreet,_that.pickupAt,_that.requestedPickupAt,_that.serviceType,_that.vehicle,_that.distanceMiles,_that.estimatedDurationMinutes,_that.flight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String direction,  String status,  List<BookingStop> stops,  int passengerCount,  int largeLuggageCount,  int includedWaitingMinutes,  bool meetAndGreet, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? pickupAt, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? requestedPickupAt,  String? serviceType,  String? vehicle,  double? distanceMiles,  int? estimatedDurationMinutes,  BookingFlight? flight)?  $default,) {final _that = this;
switch (_that) {
case _BookingLeg() when $default != null:
return $default(_that.id,_that.direction,_that.status,_that.stops,_that.passengerCount,_that.largeLuggageCount,_that.includedWaitingMinutes,_that.meetAndGreet,_that.pickupAt,_that.requestedPickupAt,_that.serviceType,_that.vehicle,_that.distanceMiles,_that.estimatedDurationMinutes,_that.flight);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingLeg extends BookingLeg {
  const _BookingLeg({required this.id, required this.direction, required this.status, required  List<BookingStop> stops, required this.passengerCount, required this.largeLuggageCount, required this.includedWaitingMinutes, required this.meetAndGreet, @JsonKey(fromJson: localDateTimeOrNull) this.pickupAt, @JsonKey(fromJson: localDateTimeOrNull) this.requestedPickupAt, this.serviceType, this.vehicle, this.distanceMiles, this.estimatedDurationMinutes, this.flight}): _stops = stops,super._();
  factory _BookingLeg.fromJson(Map<String, dynamic> json) => _$BookingLegFromJson(json);

@override final  int id;
@override final  String direction;
@override final  String status;
 final  List<BookingStop> _stops;
@override List<BookingStop> get stops {
  if (_stops is EqualUnmodifiableListView) return _stops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stops);
}

@override final  int passengerCount;
@override final  int largeLuggageCount;
@override final  int includedWaitingMinutes;
@override final  bool meetAndGreet;
/// What the customer should be ready for. On a tracked airport pickup this
/// moves with the flight, while [requestedPickupAt] is what they chose.
@override@JsonKey(fromJson: localDateTimeOrNull) final  DateTime? pickupAt;
@override@JsonKey(fromJson: localDateTimeOrNull) final  DateTime? requestedPickupAt;
@override final  String? serviceType;
@override final  String? vehicle;
@override final  double? distanceMiles;
@override final  int? estimatedDurationMinutes;
@override final  BookingFlight? flight;

/// Create a copy of BookingLeg
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingLegCopyWith<_BookingLeg> get copyWith => __$BookingLegCopyWithImpl<_BookingLeg>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingLegToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingLeg&&(identical(other.id, id) || other.id == id)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.stops, _stops)&&(identical(other.passengerCount, passengerCount) || other.passengerCount == passengerCount)&&(identical(other.largeLuggageCount, largeLuggageCount) || other.largeLuggageCount == largeLuggageCount)&&(identical(other.includedWaitingMinutes, includedWaitingMinutes) || other.includedWaitingMinutes == includedWaitingMinutes)&&(identical(other.meetAndGreet, meetAndGreet) || other.meetAndGreet == meetAndGreet)&&(identical(other.pickupAt, pickupAt) || other.pickupAt == pickupAt)&&(identical(other.requestedPickupAt, requestedPickupAt) || other.requestedPickupAt == requestedPickupAt)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&(identical(other.distanceMiles, distanceMiles) || other.distanceMiles == distanceMiles)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes)&&(identical(other.flight, flight) || other.flight == flight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,direction,status,const DeepCollectionEquality().hash(_stops),passengerCount,largeLuggageCount,includedWaitingMinutes,meetAndGreet,pickupAt,requestedPickupAt,serviceType,vehicle,distanceMiles,estimatedDurationMinutes,flight);
}

@override
String toString() {
    return 'BookingLeg(id: $id, direction: $direction, status: $status, stops: $stops, passengerCount: $passengerCount, largeLuggageCount: $largeLuggageCount, includedWaitingMinutes: $includedWaitingMinutes, meetAndGreet: $meetAndGreet, pickupAt: $pickupAt, requestedPickupAt: $requestedPickupAt, serviceType: $serviceType, vehicle: $vehicle, distanceMiles: $distanceMiles, estimatedDurationMinutes: $estimatedDurationMinutes, flight: $flight)';
}


}

/// @nodoc
abstract mixin class _$BookingLegCopyWith<$Res> implements $BookingLegCopyWith<$Res> {
  factory _$BookingLegCopyWith(_BookingLeg value, $Res Function(_BookingLeg) _then) = __$BookingLegCopyWithImpl;
@override @useResult
$Res call({
 int id, String direction, String status, List<BookingStop> stops, int passengerCount, int largeLuggageCount, int includedWaitingMinutes, bool meetAndGreet,@JsonKey(fromJson: localDateTimeOrNull) DateTime? pickupAt,@JsonKey(fromJson: localDateTimeOrNull) DateTime? requestedPickupAt, String? serviceType, String? vehicle, double? distanceMiles, int? estimatedDurationMinutes, BookingFlight? flight
});


@override $BookingFlightCopyWith<$Res>? get flight;

}
/// @nodoc
class __$BookingLegCopyWithImpl<$Res>
    implements _$BookingLegCopyWith<$Res> {
  __$BookingLegCopyWithImpl(this._self, this._then);

  final _BookingLeg _self;
  final $Res Function(_BookingLeg) _then;

/// Create a copy of BookingLeg
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? direction = null,Object? status = null,Object? stops = null,Object? passengerCount = null,Object? largeLuggageCount = null,Object? includedWaitingMinutes = null,Object? meetAndGreet = null,Object? pickupAt = freezed,Object? requestedPickupAt = freezed,Object? serviceType = freezed,Object? vehicle = freezed,Object? distanceMiles = freezed,Object? estimatedDurationMinutes = freezed,Object? flight = freezed,}) {
  return _then(_BookingLeg(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,stops: null == stops ? _self._stops : stops // ignore: cast_nullable_to_non_nullable
as List<BookingStop>,passengerCount: null == passengerCount ? _self.passengerCount : passengerCount // ignore: cast_nullable_to_non_nullable
as int,largeLuggageCount: null == largeLuggageCount ? _self.largeLuggageCount : largeLuggageCount // ignore: cast_nullable_to_non_nullable
as int,includedWaitingMinutes: null == includedWaitingMinutes ? _self.includedWaitingMinutes : includedWaitingMinutes // ignore: cast_nullable_to_non_nullable
as int,meetAndGreet: null == meetAndGreet ? _self.meetAndGreet : meetAndGreet // ignore: cast_nullable_to_non_nullable
as bool,pickupAt: freezed == pickupAt ? _self.pickupAt : pickupAt // ignore: cast_nullable_to_non_nullable
as DateTime?,requestedPickupAt: freezed == requestedPickupAt ? _self.requestedPickupAt : requestedPickupAt // ignore: cast_nullable_to_non_nullable
as DateTime?,serviceType: freezed == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String?,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as String?,distanceMiles: freezed == distanceMiles ? _self.distanceMiles : distanceMiles // ignore: cast_nullable_to_non_nullable
as double?,estimatedDurationMinutes: freezed == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,flight: freezed == flight ? _self.flight : flight // ignore: cast_nullable_to_non_nullable
as BookingFlight?,
  ));
}

/// Create a copy of BookingLeg
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingFlightCopyWith<$Res>? get flight {
    if (_self.flight == null) {
    return null;
  }

  return $BookingFlightCopyWith<$Res>(_self.flight!, (value) {
    return _then(_self.copyWith(flight: value));
  });
}
}


/// @nodoc
mixin _$FareItem {

 String get label; double get amount;
/// Create a copy of FareItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FareItemCopyWith<FareItem> get copyWith => _$FareItemCopyWithImpl<FareItem>(this as FareItem, _$identity);

  /// Serializes this FareItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FareItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FareItem&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.amount, _this.amount) || other.amount == _this.amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FareItem;
  return Object.hash(runtimeType,_this.label,_this.amount);
}

@override
String toString() {
  final _this = this as FareItem;
  return 'FareItem(label: ${_this.label}, amount: ${_this.amount})';
}


}

/// @nodoc
abstract mixin class $FareItemCopyWith<$Res>  {
  factory $FareItemCopyWith(FareItem value, $Res Function(FareItem) _then) = _$FareItemCopyWithImpl;
@useResult
$Res call({
 String label, double amount
});




}
/// @nodoc
class _$FareItemCopyWithImpl<$Res>
    implements $FareItemCopyWith<$Res> {
  _$FareItemCopyWithImpl(this._self, this._then);

  final FareItem _self;
  final $Res Function(FareItem) _then;

/// Create a copy of FareItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? amount = null,}) {
  return _then(FareItem(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [FareItem].
extension FareItemPatterns on FareItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FareItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FareItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FareItem value)  $default,){
final _that = this;
switch (_that) {
case _FareItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FareItem value)?  $default,){
final _that = this;
switch (_that) {
case _FareItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  double amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FareItem() when $default != null:
return $default(_that.label,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  double amount)  $default,) {final _that = this;
switch (_that) {
case _FareItem():
return $default(_that.label,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  double amount)?  $default,) {final _that = this;
switch (_that) {
case _FareItem() when $default != null:
return $default(_that.label,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FareItem implements FareItem {
  const _FareItem({required this.label, required this.amount});
  factory _FareItem.fromJson(Map<String, dynamic> json) => _$FareItemFromJson(json);

@override final  String label;
@override final  double amount;

/// Create a copy of FareItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FareItemCopyWith<_FareItem> get copyWith => __$FareItemCopyWithImpl<_FareItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FareItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FareItem&&(identical(other.label, label) || other.label == label)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,amount);
}

@override
String toString() {
    return 'FareItem(label: $label, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$FareItemCopyWith<$Res> implements $FareItemCopyWith<$Res> {
  factory _$FareItemCopyWith(_FareItem value, $Res Function(_FareItem) _then) = __$FareItemCopyWithImpl;
@override @useResult
$Res call({
 String label, double amount
});




}
/// @nodoc
class __$FareItemCopyWithImpl<$Res>
    implements _$FareItemCopyWith<$Res> {
  __$FareItemCopyWithImpl(this._self, this._then);

  final _FareItem _self;
  final $Res Function(_FareItem) _then;

/// Create a copy of FareItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? amount = null,}) {
  return _then(_FareItem(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$CancellationRequest {

 int get id; String get status; String get scope; String get reason; double get recommendedRefundPercentage; String? get legDirection;@JsonKey(fromJson: localDateTimeOrNull) DateTime? get requestedAt;
/// Create a copy of CancellationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancellationRequestCopyWith<CancellationRequest> get copyWith => _$CancellationRequestCopyWithImpl<CancellationRequest>(this as CancellationRequest, _$identity);

  /// Serializes this CancellationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CancellationRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancellationRequest&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.scope, _this.scope) || other.scope == _this.scope)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.recommendedRefundPercentage, _this.recommendedRefundPercentage) || other.recommendedRefundPercentage == _this.recommendedRefundPercentage)&&(identical(other.legDirection, _this.legDirection) || other.legDirection == _this.legDirection)&&(identical(other.requestedAt, _this.requestedAt) || other.requestedAt == _this.requestedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CancellationRequest;
  return Object.hash(runtimeType,_this.id,_this.status,_this.scope,_this.reason,_this.recommendedRefundPercentage,_this.legDirection,_this.requestedAt);
}

@override
String toString() {
  final _this = this as CancellationRequest;
  return 'CancellationRequest(id: ${_this.id}, status: ${_this.status}, scope: ${_this.scope}, reason: ${_this.reason}, recommendedRefundPercentage: ${_this.recommendedRefundPercentage}, legDirection: ${_this.legDirection}, requestedAt: ${_this.requestedAt})';
}


}

/// @nodoc
abstract mixin class $CancellationRequestCopyWith<$Res>  {
  factory $CancellationRequestCopyWith(CancellationRequest value, $Res Function(CancellationRequest) _then) = _$CancellationRequestCopyWithImpl;
@useResult
$Res call({
 int id, String status, String scope, String reason, double recommendedRefundPercentage, String? legDirection,@JsonKey(fromJson: localDateTimeOrNull) DateTime? requestedAt
});




}
/// @nodoc
class _$CancellationRequestCopyWithImpl<$Res>
    implements $CancellationRequestCopyWith<$Res> {
  _$CancellationRequestCopyWithImpl(this._self, this._then);

  final CancellationRequest _self;
  final $Res Function(CancellationRequest) _then;

/// Create a copy of CancellationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? scope = null,Object? reason = null,Object? recommendedRefundPercentage = null,Object? legDirection = freezed,Object? requestedAt = freezed,}) {
  return _then(CancellationRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,recommendedRefundPercentage: null == recommendedRefundPercentage ? _self.recommendedRefundPercentage : recommendedRefundPercentage // ignore: cast_nullable_to_non_nullable
as double,legDirection: freezed == legDirection ? _self.legDirection : legDirection // ignore: cast_nullable_to_non_nullable
as String?,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CancellationRequest].
extension CancellationRequestPatterns on CancellationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CancellationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CancellationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CancellationRequest value)  $default,){
final _that = this;
switch (_that) {
case _CancellationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CancellationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CancellationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String status,  String scope,  String reason,  double recommendedRefundPercentage,  String? legDirection, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? requestedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CancellationRequest() when $default != null:
return $default(_that.id,_that.status,_that.scope,_that.reason,_that.recommendedRefundPercentage,_that.legDirection,_that.requestedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String status,  String scope,  String reason,  double recommendedRefundPercentage,  String? legDirection, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? requestedAt)  $default,) {final _that = this;
switch (_that) {
case _CancellationRequest():
return $default(_that.id,_that.status,_that.scope,_that.reason,_that.recommendedRefundPercentage,_that.legDirection,_that.requestedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String status,  String scope,  String reason,  double recommendedRefundPercentage,  String? legDirection, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? requestedAt)?  $default,) {final _that = this;
switch (_that) {
case _CancellationRequest() when $default != null:
return $default(_that.id,_that.status,_that.scope,_that.reason,_that.recommendedRefundPercentage,_that.legDirection,_that.requestedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CancellationRequest implements CancellationRequest {
  const _CancellationRequest({required this.id, required this.status, required this.scope, required this.reason, required this.recommendedRefundPercentage, this.legDirection, @JsonKey(fromJson: localDateTimeOrNull) this.requestedAt});
  factory _CancellationRequest.fromJson(Map<String, dynamic> json) => _$CancellationRequestFromJson(json);

@override final  int id;
@override final  String status;
@override final  String scope;
@override final  String reason;
@override final  double recommendedRefundPercentage;
@override final  String? legDirection;
@override@JsonKey(fromJson: localDateTimeOrNull) final  DateTime? requestedAt;

/// Create a copy of CancellationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CancellationRequestCopyWith<_CancellationRequest> get copyWith => __$CancellationRequestCopyWithImpl<_CancellationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CancellationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancellationRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.recommendedRefundPercentage, recommendedRefundPercentage) || other.recommendedRefundPercentage == recommendedRefundPercentage)&&(identical(other.legDirection, legDirection) || other.legDirection == legDirection)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,status,scope,reason,recommendedRefundPercentage,legDirection,requestedAt);
}

@override
String toString() {
    return 'CancellationRequest(id: $id, status: $status, scope: $scope, reason: $reason, recommendedRefundPercentage: $recommendedRefundPercentage, legDirection: $legDirection, requestedAt: $requestedAt)';
}


}

/// @nodoc
abstract mixin class _$CancellationRequestCopyWith<$Res> implements $CancellationRequestCopyWith<$Res> {
  factory _$CancellationRequestCopyWith(_CancellationRequest value, $Res Function(_CancellationRequest) _then) = __$CancellationRequestCopyWithImpl;
@override @useResult
$Res call({
 int id, String status, String scope, String reason, double recommendedRefundPercentage, String? legDirection,@JsonKey(fromJson: localDateTimeOrNull) DateTime? requestedAt
});




}
/// @nodoc
class __$CancellationRequestCopyWithImpl<$Res>
    implements _$CancellationRequestCopyWith<$Res> {
  __$CancellationRequestCopyWithImpl(this._self, this._then);

  final _CancellationRequest _self;
  final $Res Function(_CancellationRequest) _then;

/// Create a copy of CancellationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? scope = null,Object? reason = null,Object? recommendedRefundPercentage = null,Object? legDirection = freezed,Object? requestedAt = freezed,}) {
  return _then(_CancellationRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,recommendedRefundPercentage: null == recommendedRefundPercentage ? _self.recommendedRefundPercentage : recommendedRefundPercentage // ignore: cast_nullable_to_non_nullable
as double,legDirection: freezed == legDirection ? _self.legDirection : legDirection // ignore: cast_nullable_to_non_nullable
as String?,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Booking {

 String get reference; String get status; String get statusLabel; String get paymentStatus; String get paymentStatusLabel; double get totalAmount; String get currency; String get journeyType; bool get canPay; bool get isCancellable;@JsonKey(fromJson: localDateTimeOrNull) DateTime? get pickupAt; String? get pickupAddress; String? get dropoffAddress; String? get vehicle;@JsonKey(fromJson: localDateTimeOrNull) DateTime? get createdAt;@JsonKey(fromJson: localDateTimeOrNull) DateTime? get cancelledAt; String? get customerName; String? get customerPhone; String? get customerEmail; String? get customerNotes; List<BookingLeg> get legs; List<FareItem> get fareItems; CancellationRequest? get cancellationRequest;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Booking;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.statusLabel, _this.statusLabel) || other.statusLabel == _this.statusLabel)&&(identical(other.paymentStatus, _this.paymentStatus) || other.paymentStatus == _this.paymentStatus)&&(identical(other.paymentStatusLabel, _this.paymentStatusLabel) || other.paymentStatusLabel == _this.paymentStatusLabel)&&(identical(other.totalAmount, _this.totalAmount) || other.totalAmount == _this.totalAmount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.journeyType, _this.journeyType) || other.journeyType == _this.journeyType)&&(identical(other.canPay, _this.canPay) || other.canPay == _this.canPay)&&(identical(other.isCancellable, _this.isCancellable) || other.isCancellable == _this.isCancellable)&&(identical(other.pickupAt, _this.pickupAt) || other.pickupAt == _this.pickupAt)&&(identical(other.pickupAddress, _this.pickupAddress) || other.pickupAddress == _this.pickupAddress)&&(identical(other.dropoffAddress, _this.dropoffAddress) || other.dropoffAddress == _this.dropoffAddress)&&(identical(other.vehicle, _this.vehicle) || other.vehicle == _this.vehicle)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.cancelledAt, _this.cancelledAt) || other.cancelledAt == _this.cancelledAt)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.customerPhone, _this.customerPhone) || other.customerPhone == _this.customerPhone)&&(identical(other.customerEmail, _this.customerEmail) || other.customerEmail == _this.customerEmail)&&(identical(other.customerNotes, _this.customerNotes) || other.customerNotes == _this.customerNotes)&&const DeepCollectionEquality().equals(other.legs, _this.legs)&&const DeepCollectionEquality().equals(other.fareItems, _this.fareItems)&&(identical(other.cancellationRequest, _this.cancellationRequest) || other.cancellationRequest == _this.cancellationRequest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Booking;
  return Object.hashAll([runtimeType,_this.reference,_this.status,_this.statusLabel,_this.paymentStatus,_this.paymentStatusLabel,_this.totalAmount,_this.currency,_this.journeyType,_this.canPay,_this.isCancellable,_this.pickupAt,_this.pickupAddress,_this.dropoffAddress,_this.vehicle,_this.createdAt,_this.cancelledAt,_this.customerName,_this.customerPhone,_this.customerEmail,_this.customerNotes,const DeepCollectionEquality().hash(_this.legs),const DeepCollectionEquality().hash(_this.fareItems),_this.cancellationRequest]);
}

@override
String toString() {
  final _this = this as Booking;
  return 'Booking(reference: ${_this.reference}, status: ${_this.status}, statusLabel: ${_this.statusLabel}, paymentStatus: ${_this.paymentStatus}, paymentStatusLabel: ${_this.paymentStatusLabel}, totalAmount: ${_this.totalAmount}, currency: ${_this.currency}, journeyType: ${_this.journeyType}, canPay: ${_this.canPay}, isCancellable: ${_this.isCancellable}, pickupAt: ${_this.pickupAt}, pickupAddress: ${_this.pickupAddress}, dropoffAddress: ${_this.dropoffAddress}, vehicle: ${_this.vehicle}, createdAt: ${_this.createdAt}, cancelledAt: ${_this.cancelledAt}, customerName: ${_this.customerName}, customerPhone: ${_this.customerPhone}, customerEmail: ${_this.customerEmail}, customerNotes: ${_this.customerNotes}, legs: ${_this.legs}, fareItems: ${_this.fareItems}, cancellationRequest: ${_this.cancellationRequest})';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String reference, String status, String statusLabel, String paymentStatus, String paymentStatusLabel, double totalAmount, String currency, String journeyType, bool canPay, bool isCancellable,@JsonKey(fromJson: localDateTimeOrNull) DateTime? pickupAt, String? pickupAddress, String? dropoffAddress, String? vehicle,@JsonKey(fromJson: localDateTimeOrNull) DateTime? createdAt,@JsonKey(fromJson: localDateTimeOrNull) DateTime? cancelledAt, String? customerName, String? customerPhone, String? customerEmail, String? customerNotes, List<BookingLeg> legs, List<FareItem> fareItems, CancellationRequest? cancellationRequest
});


$CancellationRequestCopyWith<$Res>? get cancellationRequest;

}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reference = null,Object? status = null,Object? statusLabel = null,Object? paymentStatus = null,Object? paymentStatusLabel = null,Object? totalAmount = null,Object? currency = null,Object? journeyType = null,Object? canPay = null,Object? isCancellable = null,Object? pickupAt = freezed,Object? pickupAddress = freezed,Object? dropoffAddress = freezed,Object? vehicle = freezed,Object? createdAt = freezed,Object? cancelledAt = freezed,Object? customerName = freezed,Object? customerPhone = freezed,Object? customerEmail = freezed,Object? customerNotes = freezed,Object? legs = null,Object? fareItems = null,Object? cancellationRequest = freezed,}) {
  return _then(Booking(
reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,paymentStatusLabel: null == paymentStatusLabel ? _self.paymentStatusLabel : paymentStatusLabel // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,journeyType: null == journeyType ? _self.journeyType : journeyType // ignore: cast_nullable_to_non_nullable
as String,canPay: null == canPay ? _self.canPay : canPay // ignore: cast_nullable_to_non_nullable
as bool,isCancellable: null == isCancellable ? _self.isCancellable : isCancellable // ignore: cast_nullable_to_non_nullable
as bool,pickupAt: freezed == pickupAt ? _self.pickupAt : pickupAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pickupAddress: freezed == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String?,dropoffAddress: freezed == dropoffAddress ? _self.dropoffAddress : dropoffAddress // ignore: cast_nullable_to_non_nullable
as String?,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerNotes: freezed == customerNotes ? _self.customerNotes : customerNotes // ignore: cast_nullable_to_non_nullable
as String?,legs: null == legs ? _self.legs : legs // ignore: cast_nullable_to_non_nullable
as List<BookingLeg>,fareItems: null == fareItems ? _self.fareItems : fareItems // ignore: cast_nullable_to_non_nullable
as List<FareItem>,cancellationRequest: freezed == cancellationRequest ? _self.cancellationRequest : cancellationRequest // ignore: cast_nullable_to_non_nullable
as CancellationRequest?,
  ));
}
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CancellationRequestCopyWith<$Res>? get cancellationRequest {
    if (_self.cancellationRequest == null) {
    return null;
  }

  return $CancellationRequestCopyWith<$Res>(_self.cancellationRequest!, (value) {
    return _then(_self.copyWith(cancellationRequest: value));
  });
}
}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reference,  String status,  String statusLabel,  String paymentStatus,  String paymentStatusLabel,  double totalAmount,  String currency,  String journeyType,  bool canPay,  bool isCancellable, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? pickupAt,  String? pickupAddress,  String? dropoffAddress,  String? vehicle, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? createdAt, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? cancelledAt,  String? customerName,  String? customerPhone,  String? customerEmail,  String? customerNotes,  List<BookingLeg> legs,  List<FareItem> fareItems,  CancellationRequest? cancellationRequest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.reference,_that.status,_that.statusLabel,_that.paymentStatus,_that.paymentStatusLabel,_that.totalAmount,_that.currency,_that.journeyType,_that.canPay,_that.isCancellable,_that.pickupAt,_that.pickupAddress,_that.dropoffAddress,_that.vehicle,_that.createdAt,_that.cancelledAt,_that.customerName,_that.customerPhone,_that.customerEmail,_that.customerNotes,_that.legs,_that.fareItems,_that.cancellationRequest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reference,  String status,  String statusLabel,  String paymentStatus,  String paymentStatusLabel,  double totalAmount,  String currency,  String journeyType,  bool canPay,  bool isCancellable, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? pickupAt,  String? pickupAddress,  String? dropoffAddress,  String? vehicle, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? createdAt, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? cancelledAt,  String? customerName,  String? customerPhone,  String? customerEmail,  String? customerNotes,  List<BookingLeg> legs,  List<FareItem> fareItems,  CancellationRequest? cancellationRequest)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.reference,_that.status,_that.statusLabel,_that.paymentStatus,_that.paymentStatusLabel,_that.totalAmount,_that.currency,_that.journeyType,_that.canPay,_that.isCancellable,_that.pickupAt,_that.pickupAddress,_that.dropoffAddress,_that.vehicle,_that.createdAt,_that.cancelledAt,_that.customerName,_that.customerPhone,_that.customerEmail,_that.customerNotes,_that.legs,_that.fareItems,_that.cancellationRequest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reference,  String status,  String statusLabel,  String paymentStatus,  String paymentStatusLabel,  double totalAmount,  String currency,  String journeyType,  bool canPay,  bool isCancellable, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? pickupAt,  String? pickupAddress,  String? dropoffAddress,  String? vehicle, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? createdAt, @JsonKey(fromJson: localDateTimeOrNull)  DateTime? cancelledAt,  String? customerName,  String? customerPhone,  String? customerEmail,  String? customerNotes,  List<BookingLeg> legs,  List<FareItem> fareItems,  CancellationRequest? cancellationRequest)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.reference,_that.status,_that.statusLabel,_that.paymentStatus,_that.paymentStatusLabel,_that.totalAmount,_that.currency,_that.journeyType,_that.canPay,_that.isCancellable,_that.pickupAt,_that.pickupAddress,_that.dropoffAddress,_that.vehicle,_that.createdAt,_that.cancelledAt,_that.customerName,_that.customerPhone,_that.customerEmail,_that.customerNotes,_that.legs,_that.fareItems,_that.cancellationRequest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking extends Booking {
  const _Booking({required this.reference, required this.status, required this.statusLabel, required this.paymentStatus, required this.paymentStatusLabel, required this.totalAmount, required this.currency, required this.journeyType, required this.canPay, required this.isCancellable, @JsonKey(fromJson: localDateTimeOrNull) this.pickupAt, this.pickupAddress, this.dropoffAddress, this.vehicle, @JsonKey(fromJson: localDateTimeOrNull) this.createdAt, @JsonKey(fromJson: localDateTimeOrNull) this.cancelledAt, this.customerName, this.customerPhone, this.customerEmail, this.customerNotes,  List<BookingLeg> legs = const [],  List<FareItem> fareItems = const [], this.cancellationRequest}): _legs = legs,_fareItems = fareItems,super._();
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String reference;
@override final  String status;
@override final  String statusLabel;
@override final  String paymentStatus;
@override final  String paymentStatusLabel;
@override final  double totalAmount;
@override final  String currency;
@override final  String journeyType;
@override final  bool canPay;
@override final  bool isCancellable;
@override@JsonKey(fromJson: localDateTimeOrNull) final  DateTime? pickupAt;
@override final  String? pickupAddress;
@override final  String? dropoffAddress;
@override final  String? vehicle;
@override@JsonKey(fromJson: localDateTimeOrNull) final  DateTime? createdAt;
@override@JsonKey(fromJson: localDateTimeOrNull) final  DateTime? cancelledAt;
@override final  String? customerName;
@override final  String? customerPhone;
@override final  String? customerEmail;
@override final  String? customerNotes;
 final  List<BookingLeg> _legs;
@override@JsonKey() List<BookingLeg> get legs {
  if (_legs is EqualUnmodifiableListView) return _legs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_legs);
}

 final  List<FareItem> _fareItems;
@override@JsonKey() List<FareItem> get fareItems {
  if (_fareItems is EqualUnmodifiableListView) return _fareItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fareItems);
}

@override final  CancellationRequest? cancellationRequest;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paymentStatusLabel, paymentStatusLabel) || other.paymentStatusLabel == paymentStatusLabel)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.journeyType, journeyType) || other.journeyType == journeyType)&&(identical(other.canPay, canPay) || other.canPay == canPay)&&(identical(other.isCancellable, isCancellable) || other.isCancellable == isCancellable)&&(identical(other.pickupAt, pickupAt) || other.pickupAt == pickupAt)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.dropoffAddress, dropoffAddress) || other.dropoffAddress == dropoffAddress)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerNotes, customerNotes) || other.customerNotes == customerNotes)&&const DeepCollectionEquality().equals(other.legs, _legs)&&const DeepCollectionEquality().equals(other.fareItems, _fareItems)&&(identical(other.cancellationRequest, cancellationRequest) || other.cancellationRequest == cancellationRequest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,reference,status,statusLabel,paymentStatus,paymentStatusLabel,totalAmount,currency,journeyType,canPay,isCancellable,pickupAt,pickupAddress,dropoffAddress,vehicle,createdAt,cancelledAt,customerName,customerPhone,customerEmail,customerNotes,const DeepCollectionEquality().hash(_legs),const DeepCollectionEquality().hash(_fareItems),cancellationRequest]);
}

@override
String toString() {
    return 'Booking(reference: $reference, status: $status, statusLabel: $statusLabel, paymentStatus: $paymentStatus, paymentStatusLabel: $paymentStatusLabel, totalAmount: $totalAmount, currency: $currency, journeyType: $journeyType, canPay: $canPay, isCancellable: $isCancellable, pickupAt: $pickupAt, pickupAddress: $pickupAddress, dropoffAddress: $dropoffAddress, vehicle: $vehicle, createdAt: $createdAt, cancelledAt: $cancelledAt, customerName: $customerName, customerPhone: $customerPhone, customerEmail: $customerEmail, customerNotes: $customerNotes, legs: $legs, fareItems: $fareItems, cancellationRequest: $cancellationRequest)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String reference, String status, String statusLabel, String paymentStatus, String paymentStatusLabel, double totalAmount, String currency, String journeyType, bool canPay, bool isCancellable,@JsonKey(fromJson: localDateTimeOrNull) DateTime? pickupAt, String? pickupAddress, String? dropoffAddress, String? vehicle,@JsonKey(fromJson: localDateTimeOrNull) DateTime? createdAt,@JsonKey(fromJson: localDateTimeOrNull) DateTime? cancelledAt, String? customerName, String? customerPhone, String? customerEmail, String? customerNotes, List<BookingLeg> legs, List<FareItem> fareItems, CancellationRequest? cancellationRequest
});


@override $CancellationRequestCopyWith<$Res>? get cancellationRequest;

}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reference = null,Object? status = null,Object? statusLabel = null,Object? paymentStatus = null,Object? paymentStatusLabel = null,Object? totalAmount = null,Object? currency = null,Object? journeyType = null,Object? canPay = null,Object? isCancellable = null,Object? pickupAt = freezed,Object? pickupAddress = freezed,Object? dropoffAddress = freezed,Object? vehicle = freezed,Object? createdAt = freezed,Object? cancelledAt = freezed,Object? customerName = freezed,Object? customerPhone = freezed,Object? customerEmail = freezed,Object? customerNotes = freezed,Object? legs = null,Object? fareItems = null,Object? cancellationRequest = freezed,}) {
  return _then(_Booking(
reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,paymentStatusLabel: null == paymentStatusLabel ? _self.paymentStatusLabel : paymentStatusLabel // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,journeyType: null == journeyType ? _self.journeyType : journeyType // ignore: cast_nullable_to_non_nullable
as String,canPay: null == canPay ? _self.canPay : canPay // ignore: cast_nullable_to_non_nullable
as bool,isCancellable: null == isCancellable ? _self.isCancellable : isCancellable // ignore: cast_nullable_to_non_nullable
as bool,pickupAt: freezed == pickupAt ? _self.pickupAt : pickupAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pickupAddress: freezed == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String?,dropoffAddress: freezed == dropoffAddress ? _self.dropoffAddress : dropoffAddress // ignore: cast_nullable_to_non_nullable
as String?,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,customerNotes: freezed == customerNotes ? _self.customerNotes : customerNotes // ignore: cast_nullable_to_non_nullable
as String?,legs: null == legs ? _self._legs : legs // ignore: cast_nullable_to_non_nullable
as List<BookingLeg>,fareItems: null == fareItems ? _self._fareItems : fareItems // ignore: cast_nullable_to_non_nullable
as List<FareItem>,cancellationRequest: freezed == cancellationRequest ? _self.cancellationRequest : cancellationRequest // ignore: cast_nullable_to_non_nullable
as CancellationRequest?,
  ));
}

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CancellationRequestCopyWith<$Res>? get cancellationRequest {
    if (_self.cancellationRequest == null) {
    return null;
  }

  return $CancellationRequestCopyWith<$Res>(_self.cancellationRequest!, (value) {
    return _then(_self.copyWith(cancellationRequest: value));
  });
}
}

// dart format on
