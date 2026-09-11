// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quote.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Fare {

 double get single;/// The total for both legs, or null when the vehicle cannot serve the return.
@JsonKey(name: 'return') double? get returnTotal;
/// Create a copy of Fare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FareCopyWith<Fare> get copyWith => _$FareCopyWithImpl<Fare>(this as Fare, _$identity);

  /// Serializes this Fare to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Fare;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Fare&&(identical(other.single, _this.single) || other.single == _this.single)&&(identical(other.returnTotal, _this.returnTotal) || other.returnTotal == _this.returnTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Fare;
  return Object.hash(runtimeType,_this.single,_this.returnTotal);
}

@override
String toString() {
  final _this = this as Fare;
  return 'Fare(single: ${_this.single}, returnTotal: ${_this.returnTotal})';
}


}

/// @nodoc
abstract mixin class $FareCopyWith<$Res>  {
  factory $FareCopyWith(Fare value, $Res Function(Fare) _then) = _$FareCopyWithImpl;
@useResult
$Res call({
 double single,@JsonKey(name: 'return') double? returnTotal
});




}
/// @nodoc
class _$FareCopyWithImpl<$Res>
    implements $FareCopyWith<$Res> {
  _$FareCopyWithImpl(this._self, this._then);

  final Fare _self;
  final $Res Function(Fare) _then;

/// Create a copy of Fare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? single = null,Object? returnTotal = freezed,}) {
  return _then(Fare(
single: null == single ? _self.single : single // ignore: cast_nullable_to_non_nullable
as double,returnTotal: freezed == returnTotal ? _self.returnTotal : returnTotal // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [Fare].
extension FarePatterns on Fare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Fare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Fare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Fare value)  $default,){
final _that = this;
switch (_that) {
case _Fare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Fare value)?  $default,){
final _that = this;
switch (_that) {
case _Fare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double single, @JsonKey(name: 'return')  double? returnTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Fare() when $default != null:
return $default(_that.single,_that.returnTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double single, @JsonKey(name: 'return')  double? returnTotal)  $default,) {final _that = this;
switch (_that) {
case _Fare():
return $default(_that.single,_that.returnTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double single, @JsonKey(name: 'return')  double? returnTotal)?  $default,) {final _that = this;
switch (_that) {
case _Fare() when $default != null:
return $default(_that.single,_that.returnTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Fare implements Fare {
  const _Fare({required this.single, @JsonKey(name: 'return') this.returnTotal});
  factory _Fare.fromJson(Map<String, dynamic> json) => _$FareFromJson(json);

@override final  double single;
/// The total for both legs, or null when the vehicle cannot serve the return.
@override@JsonKey(name: 'return') final  double? returnTotal;

/// Create a copy of Fare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FareCopyWith<_Fare> get copyWith => __$FareCopyWithImpl<_Fare>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FareToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Fare&&(identical(other.single, single) || other.single == single)&&(identical(other.returnTotal, returnTotal) || other.returnTotal == returnTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,single,returnTotal);
}

@override
String toString() {
    return 'Fare(single: $single, returnTotal: $returnTotal)';
}


}

/// @nodoc
abstract mixin class _$FareCopyWith<$Res> implements $FareCopyWith<$Res> {
  factory _$FareCopyWith(_Fare value, $Res Function(_Fare) _then) = __$FareCopyWithImpl;
@override @useResult
$Res call({
 double single,@JsonKey(name: 'return') double? returnTotal
});




}
/// @nodoc
class __$FareCopyWithImpl<$Res>
    implements _$FareCopyWith<$Res> {
  __$FareCopyWithImpl(this._self, this._then);

  final _Fare _self;
  final $Res Function(_Fare) _then;

/// Create a copy of Fare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? single = null,Object? returnTotal = freezed,}) {
  return _then(_Fare(
single: null == single ? _self.single : single // ignore: cast_nullable_to_non_nullable
as double,returnTotal: freezed == returnTotal ? _self.returnTotal : returnTotal // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$Quote {

@JsonKey(name: 'quote_token') String get token;@JsonKey(fromJson: localDateTime) DateTime get expiresAt; Map<String, Fare> get fares;/// Null rather than zero: a fixed-fare tour has a price but no measured
/// route, and "0.0 miles" beside it reads as a fault.
 double? get distanceMiles; int? get estimatedDurationMinutes;
/// Create a copy of Quote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuoteCopyWith<Quote> get copyWith => _$QuoteCopyWithImpl<Quote>(this as Quote, _$identity);

  /// Serializes this Quote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Quote;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Quote&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&const DeepCollectionEquality().equals(other.fares, _this.fares)&&(identical(other.distanceMiles, _this.distanceMiles) || other.distanceMiles == _this.distanceMiles)&&(identical(other.estimatedDurationMinutes, _this.estimatedDurationMinutes) || other.estimatedDurationMinutes == _this.estimatedDurationMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Quote;
  return Object.hash(runtimeType,_this.token,_this.expiresAt,const DeepCollectionEquality().hash(_this.fares),_this.distanceMiles,_this.estimatedDurationMinutes);
}

@override
String toString() {
  final _this = this as Quote;
  return 'Quote(token: ${_this.token}, expiresAt: ${_this.expiresAt}, fares: ${_this.fares}, distanceMiles: ${_this.distanceMiles}, estimatedDurationMinutes: ${_this.estimatedDurationMinutes})';
}


}

/// @nodoc
abstract mixin class $QuoteCopyWith<$Res>  {
  factory $QuoteCopyWith(Quote value, $Res Function(Quote) _then) = _$QuoteCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'quote_token') String token,@JsonKey(fromJson: localDateTime) DateTime expiresAt, Map<String, Fare> fares, double? distanceMiles, int? estimatedDurationMinutes
});




}
/// @nodoc
class _$QuoteCopyWithImpl<$Res>
    implements $QuoteCopyWith<$Res> {
  _$QuoteCopyWithImpl(this._self, this._then);

  final Quote _self;
  final $Res Function(Quote) _then;

/// Create a copy of Quote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? expiresAt = null,Object? fares = null,Object? distanceMiles = freezed,Object? estimatedDurationMinutes = freezed,}) {
  return _then(Quote(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,fares: null == fares ? _self.fares : fares // ignore: cast_nullable_to_non_nullable
as Map<String, Fare>,distanceMiles: freezed == distanceMiles ? _self.distanceMiles : distanceMiles // ignore: cast_nullable_to_non_nullable
as double?,estimatedDurationMinutes: freezed == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Quote].
extension QuotePatterns on Quote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Quote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Quote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Quote value)  $default,){
final _that = this;
switch (_that) {
case _Quote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Quote value)?  $default,){
final _that = this;
switch (_that) {
case _Quote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'quote_token')  String token, @JsonKey(fromJson: localDateTime)  DateTime expiresAt,  Map<String, Fare> fares,  double? distanceMiles,  int? estimatedDurationMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Quote() when $default != null:
return $default(_that.token,_that.expiresAt,_that.fares,_that.distanceMiles,_that.estimatedDurationMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'quote_token')  String token, @JsonKey(fromJson: localDateTime)  DateTime expiresAt,  Map<String, Fare> fares,  double? distanceMiles,  int? estimatedDurationMinutes)  $default,) {final _that = this;
switch (_that) {
case _Quote():
return $default(_that.token,_that.expiresAt,_that.fares,_that.distanceMiles,_that.estimatedDurationMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'quote_token')  String token, @JsonKey(fromJson: localDateTime)  DateTime expiresAt,  Map<String, Fare> fares,  double? distanceMiles,  int? estimatedDurationMinutes)?  $default,) {final _that = this;
switch (_that) {
case _Quote() when $default != null:
return $default(_that.token,_that.expiresAt,_that.fares,_that.distanceMiles,_that.estimatedDurationMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Quote extends Quote {
  const _Quote({@JsonKey(name: 'quote_token') required this.token, @JsonKey(fromJson: localDateTime) required this.expiresAt, required  Map<String, Fare> fares, this.distanceMiles, this.estimatedDurationMinutes}): _fares = fares,super._();
  factory _Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);

@override@JsonKey(name: 'quote_token') final  String token;
@override@JsonKey(fromJson: localDateTime) final  DateTime expiresAt;
 final  Map<String, Fare> _fares;
@override Map<String, Fare> get fares {
  if (_fares is EqualUnmodifiableMapView) return _fares;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fares);
}

/// Null rather than zero: a fixed-fare tour has a price but no measured
/// route, and "0.0 miles" beside it reads as a fault.
@override final  double? distanceMiles;
@override final  int? estimatedDurationMinutes;

/// Create a copy of Quote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuoteCopyWith<_Quote> get copyWith => __$QuoteCopyWithImpl<_Quote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuoteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Quote&&(identical(other.token, token) || other.token == token)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other.fares, _fares)&&(identical(other.distanceMiles, distanceMiles) || other.distanceMiles == distanceMiles)&&(identical(other.estimatedDurationMinutes, estimatedDurationMinutes) || other.estimatedDurationMinutes == estimatedDurationMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,token,expiresAt,const DeepCollectionEquality().hash(_fares),distanceMiles,estimatedDurationMinutes);
}

@override
String toString() {
    return 'Quote(token: $token, expiresAt: $expiresAt, fares: $fares, distanceMiles: $distanceMiles, estimatedDurationMinutes: $estimatedDurationMinutes)';
}


}

/// @nodoc
abstract mixin class _$QuoteCopyWith<$Res> implements $QuoteCopyWith<$Res> {
  factory _$QuoteCopyWith(_Quote value, $Res Function(_Quote) _then) = __$QuoteCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'quote_token') String token,@JsonKey(fromJson: localDateTime) DateTime expiresAt, Map<String, Fare> fares, double? distanceMiles, int? estimatedDurationMinutes
});




}
/// @nodoc
class __$QuoteCopyWithImpl<$Res>
    implements _$QuoteCopyWith<$Res> {
  __$QuoteCopyWithImpl(this._self, this._then);

  final _Quote _self;
  final $Res Function(_Quote) _then;

/// Create a copy of Quote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? expiresAt = null,Object? fares = null,Object? distanceMiles = freezed,Object? estimatedDurationMinutes = freezed,}) {
  return _then(_Quote(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,fares: null == fares ? _self._fares : fares // ignore: cast_nullable_to_non_nullable
as Map<String, Fare>,distanceMiles: freezed == distanceMiles ? _self.distanceMiles : distanceMiles // ignore: cast_nullable_to_non_nullable
as double?,estimatedDurationMinutes: freezed == estimatedDurationMinutes ? _self.estimatedDurationMinutes : estimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
