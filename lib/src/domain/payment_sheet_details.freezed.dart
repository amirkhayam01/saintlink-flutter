// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_sheet_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentSheetDetails {

/// `stripe` for a real card, `fake` while the backend runs
/// `PAYMENTS_DRIVER=fake` — the app then shows a labelled test sheet.
 String get provider; String get clientSecret; String get publishableKey; String get merchantName; double get amount; String get currency;
/// Create a copy of PaymentSheetDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentSheetDetailsCopyWith<PaymentSheetDetails> get copyWith => _$PaymentSheetDetailsCopyWithImpl<PaymentSheetDetails>(this as PaymentSheetDetails, _$identity);

  /// Serializes this PaymentSheetDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaymentSheetDetails;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentSheetDetails&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.clientSecret, _this.clientSecret) || other.clientSecret == _this.clientSecret)&&(identical(other.publishableKey, _this.publishableKey) || other.publishableKey == _this.publishableKey)&&(identical(other.merchantName, _this.merchantName) || other.merchantName == _this.merchantName)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaymentSheetDetails;
  return Object.hash(runtimeType,_this.provider,_this.clientSecret,_this.publishableKey,_this.merchantName,_this.amount,_this.currency);
}

@override
String toString() {
  final _this = this as PaymentSheetDetails;
  return 'PaymentSheetDetails(provider: ${_this.provider}, clientSecret: ${_this.clientSecret}, publishableKey: ${_this.publishableKey}, merchantName: ${_this.merchantName}, amount: ${_this.amount}, currency: ${_this.currency})';
}


}

/// @nodoc
abstract mixin class $PaymentSheetDetailsCopyWith<$Res>  {
  factory $PaymentSheetDetailsCopyWith(PaymentSheetDetails value, $Res Function(PaymentSheetDetails) _then) = _$PaymentSheetDetailsCopyWithImpl;
@useResult
$Res call({
 String provider, String clientSecret, String publishableKey, String merchantName, double amount, String currency
});




}
/// @nodoc
class _$PaymentSheetDetailsCopyWithImpl<$Res>
    implements $PaymentSheetDetailsCopyWith<$Res> {
  _$PaymentSheetDetailsCopyWithImpl(this._self, this._then);

  final PaymentSheetDetails _self;
  final $Res Function(PaymentSheetDetails) _then;

/// Create a copy of PaymentSheetDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? clientSecret = null,Object? publishableKey = null,Object? merchantName = null,Object? amount = null,Object? currency = null,}) {
  return _then(PaymentSheetDetails(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,clientSecret: null == clientSecret ? _self.clientSecret : clientSecret // ignore: cast_nullable_to_non_nullable
as String,publishableKey: null == publishableKey ? _self.publishableKey : publishableKey // ignore: cast_nullable_to_non_nullable
as String,merchantName: null == merchantName ? _self.merchantName : merchantName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentSheetDetails].
extension PaymentSheetDetailsPatterns on PaymentSheetDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentSheetDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentSheetDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentSheetDetails value)  $default,){
final _that = this;
switch (_that) {
case _PaymentSheetDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentSheetDetails value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentSheetDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String provider,  String clientSecret,  String publishableKey,  String merchantName,  double amount,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentSheetDetails() when $default != null:
return $default(_that.provider,_that.clientSecret,_that.publishableKey,_that.merchantName,_that.amount,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String provider,  String clientSecret,  String publishableKey,  String merchantName,  double amount,  String currency)  $default,) {final _that = this;
switch (_that) {
case _PaymentSheetDetails():
return $default(_that.provider,_that.clientSecret,_that.publishableKey,_that.merchantName,_that.amount,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String provider,  String clientSecret,  String publishableKey,  String merchantName,  double amount,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _PaymentSheetDetails() when $default != null:
return $default(_that.provider,_that.clientSecret,_that.publishableKey,_that.merchantName,_that.amount,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentSheetDetails extends PaymentSheetDetails {
  const _PaymentSheetDetails({required this.provider, required this.clientSecret, required this.publishableKey, required this.merchantName, required this.amount, required this.currency}): super._();
  factory _PaymentSheetDetails.fromJson(Map<String, dynamic> json) => _$PaymentSheetDetailsFromJson(json);

/// `stripe` for a real card, `fake` while the backend runs
/// `PAYMENTS_DRIVER=fake` — the app then shows a labelled test sheet.
@override final  String provider;
@override final  String clientSecret;
@override final  String publishableKey;
@override final  String merchantName;
@override final  double amount;
@override final  String currency;

/// Create a copy of PaymentSheetDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentSheetDetailsCopyWith<_PaymentSheetDetails> get copyWith => __$PaymentSheetDetailsCopyWithImpl<_PaymentSheetDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentSheetDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentSheetDetails&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.clientSecret, clientSecret) || other.clientSecret == clientSecret)&&(identical(other.publishableKey, publishableKey) || other.publishableKey == publishableKey)&&(identical(other.merchantName, merchantName) || other.merchantName == merchantName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,provider,clientSecret,publishableKey,merchantName,amount,currency);
}

@override
String toString() {
    return 'PaymentSheetDetails(provider: $provider, clientSecret: $clientSecret, publishableKey: $publishableKey, merchantName: $merchantName, amount: $amount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$PaymentSheetDetailsCopyWith<$Res> implements $PaymentSheetDetailsCopyWith<$Res> {
  factory _$PaymentSheetDetailsCopyWith(_PaymentSheetDetails value, $Res Function(_PaymentSheetDetails) _then) = __$PaymentSheetDetailsCopyWithImpl;
@override @useResult
$Res call({
 String provider, String clientSecret, String publishableKey, String merchantName, double amount, String currency
});




}
/// @nodoc
class __$PaymentSheetDetailsCopyWithImpl<$Res>
    implements _$PaymentSheetDetailsCopyWith<$Res> {
  __$PaymentSheetDetailsCopyWithImpl(this._self, this._then);

  final _PaymentSheetDetails _self;
  final $Res Function(_PaymentSheetDetails) _then;

/// Create a copy of PaymentSheetDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? clientSecret = null,Object? publishableKey = null,Object? merchantName = null,Object? amount = null,Object? currency = null,}) {
  return _then(_PaymentSheetDetails(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,clientSecret: null == clientSecret ? _self.clientSecret : clientSecret // ignore: cast_nullable_to_non_nullable
as String,publishableKey: null == publishableKey ? _self.publishableKey : publishableKey // ignore: cast_nullable_to_non_nullable
as String,merchantName: null == merchantName ? _self.merchantName : merchantName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
