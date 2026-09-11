// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Customer {

 int get id; String get name; String get firstName; String? get lastName; String? get email; String get phone; String get maskedPhone; bool get marketingConsent;
/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerCopyWith<Customer> get copyWith => _$CustomerCopyWithImpl<Customer>(this as Customer, _$identity);

  /// Serializes this Customer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Customer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Customer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.maskedPhone, _this.maskedPhone) || other.maskedPhone == _this.maskedPhone)&&(identical(other.marketingConsent, _this.marketingConsent) || other.marketingConsent == _this.marketingConsent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Customer;
  return Object.hash(runtimeType,_this.id,_this.name,_this.firstName,_this.lastName,_this.email,_this.phone,_this.maskedPhone,_this.marketingConsent);
}

@override
String toString() {
  final _this = this as Customer;
  return 'Customer(id: ${_this.id}, name: ${_this.name}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, email: ${_this.email}, phone: ${_this.phone}, maskedPhone: ${_this.maskedPhone}, marketingConsent: ${_this.marketingConsent})';
}


}

/// @nodoc
abstract mixin class $CustomerCopyWith<$Res>  {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) _then) = _$CustomerCopyWithImpl;
@useResult
$Res call({
 int id, String name, String firstName, String? lastName, String? email, String phone, String maskedPhone, bool marketingConsent
});




}
/// @nodoc
class _$CustomerCopyWithImpl<$Res>
    implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._self, this._then);

  final Customer _self;
  final $Res Function(Customer) _then;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? firstName = null,Object? lastName = freezed,Object? email = freezed,Object? phone = null,Object? maskedPhone = null,Object? marketingConsent = null,}) {
  return _then(Customer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,maskedPhone: null == maskedPhone ? _self.maskedPhone : maskedPhone // ignore: cast_nullable_to_non_nullable
as String,marketingConsent: null == marketingConsent ? _self.marketingConsent : marketingConsent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Customer].
extension CustomerPatterns on Customer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Customer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Customer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Customer value)  $default,){
final _that = this;
switch (_that) {
case _Customer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Customer value)?  $default,){
final _that = this;
switch (_that) {
case _Customer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String firstName,  String? lastName,  String? email,  String phone,  String maskedPhone,  bool marketingConsent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that.id,_that.name,_that.firstName,_that.lastName,_that.email,_that.phone,_that.maskedPhone,_that.marketingConsent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String firstName,  String? lastName,  String? email,  String phone,  String maskedPhone,  bool marketingConsent)  $default,) {final _that = this;
switch (_that) {
case _Customer():
return $default(_that.id,_that.name,_that.firstName,_that.lastName,_that.email,_that.phone,_that.maskedPhone,_that.marketingConsent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String firstName,  String? lastName,  String? email,  String phone,  String maskedPhone,  bool marketingConsent)?  $default,) {final _that = this;
switch (_that) {
case _Customer() when $default != null:
return $default(_that.id,_that.name,_that.firstName,_that.lastName,_that.email,_that.phone,_that.maskedPhone,_that.marketingConsent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Customer implements Customer {
  const _Customer({required this.id, required this.name, required this.firstName, this.lastName, this.email, required this.phone, required this.maskedPhone, required this.marketingConsent});
  factory _Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);

@override final  int id;
@override final  String name;
@override final  String firstName;
@override final  String? lastName;
@override final  String? email;
@override final  String phone;
@override final  String maskedPhone;
@override final  bool marketingConsent;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerCopyWith<_Customer> get copyWith => __$CustomerCopyWithImpl<_Customer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Customer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.maskedPhone, maskedPhone) || other.maskedPhone == maskedPhone)&&(identical(other.marketingConsent, marketingConsent) || other.marketingConsent == marketingConsent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,firstName,lastName,email,phone,maskedPhone,marketingConsent);
}

@override
String toString() {
    return 'Customer(id: $id, name: $name, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, maskedPhone: $maskedPhone, marketingConsent: $marketingConsent)';
}


}

/// @nodoc
abstract mixin class _$CustomerCopyWith<$Res> implements $CustomerCopyWith<$Res> {
  factory _$CustomerCopyWith(_Customer value, $Res Function(_Customer) _then) = __$CustomerCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String firstName, String? lastName, String? email, String phone, String maskedPhone, bool marketingConsent
});




}
/// @nodoc
class __$CustomerCopyWithImpl<$Res>
    implements _$CustomerCopyWith<$Res> {
  __$CustomerCopyWithImpl(this._self, this._then);

  final _Customer _self;
  final $Res Function(_Customer) _then;

/// Create a copy of Customer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? firstName = null,Object? lastName = freezed,Object? email = freezed,Object? phone = null,Object? maskedPhone = null,Object? marketingConsent = null,}) {
  return _then(_Customer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,maskedPhone: null == maskedPhone ? _self.maskedPhone : maskedPhone // ignore: cast_nullable_to_non_nullable
as String,marketingConsent: null == marketingConsent ? _self.marketingConsent : marketingConsent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SignInCodeRequest {

 String get maskedPhone;@JsonKey(fromJson: localDateTime) DateTime get expiresAt; int get resendAfterSeconds;
/// Create a copy of SignInCodeRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignInCodeRequestCopyWith<SignInCodeRequest> get copyWith => _$SignInCodeRequestCopyWithImpl<SignInCodeRequest>(this as SignInCodeRequest, _$identity);

  /// Serializes this SignInCodeRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SignInCodeRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignInCodeRequest&&(identical(other.maskedPhone, _this.maskedPhone) || other.maskedPhone == _this.maskedPhone)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.resendAfterSeconds, _this.resendAfterSeconds) || other.resendAfterSeconds == _this.resendAfterSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SignInCodeRequest;
  return Object.hash(runtimeType,_this.maskedPhone,_this.expiresAt,_this.resendAfterSeconds);
}

@override
String toString() {
  final _this = this as SignInCodeRequest;
  return 'SignInCodeRequest(maskedPhone: ${_this.maskedPhone}, expiresAt: ${_this.expiresAt}, resendAfterSeconds: ${_this.resendAfterSeconds})';
}


}

/// @nodoc
abstract mixin class $SignInCodeRequestCopyWith<$Res>  {
  factory $SignInCodeRequestCopyWith(SignInCodeRequest value, $Res Function(SignInCodeRequest) _then) = _$SignInCodeRequestCopyWithImpl;
@useResult
$Res call({
 String maskedPhone,@JsonKey(fromJson: localDateTime) DateTime expiresAt, int resendAfterSeconds
});




}
/// @nodoc
class _$SignInCodeRequestCopyWithImpl<$Res>
    implements $SignInCodeRequestCopyWith<$Res> {
  _$SignInCodeRequestCopyWithImpl(this._self, this._then);

  final SignInCodeRequest _self;
  final $Res Function(SignInCodeRequest) _then;

/// Create a copy of SignInCodeRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maskedPhone = null,Object? expiresAt = null,Object? resendAfterSeconds = null,}) {
  return _then(SignInCodeRequest(
maskedPhone: null == maskedPhone ? _self.maskedPhone : maskedPhone // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,resendAfterSeconds: null == resendAfterSeconds ? _self.resendAfterSeconds : resendAfterSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SignInCodeRequest].
extension SignInCodeRequestPatterns on SignInCodeRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignInCodeRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignInCodeRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignInCodeRequest value)  $default,){
final _that = this;
switch (_that) {
case _SignInCodeRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignInCodeRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SignInCodeRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String maskedPhone, @JsonKey(fromJson: localDateTime)  DateTime expiresAt,  int resendAfterSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignInCodeRequest() when $default != null:
return $default(_that.maskedPhone,_that.expiresAt,_that.resendAfterSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String maskedPhone, @JsonKey(fromJson: localDateTime)  DateTime expiresAt,  int resendAfterSeconds)  $default,) {final _that = this;
switch (_that) {
case _SignInCodeRequest():
return $default(_that.maskedPhone,_that.expiresAt,_that.resendAfterSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String maskedPhone, @JsonKey(fromJson: localDateTime)  DateTime expiresAt,  int resendAfterSeconds)?  $default,) {final _that = this;
switch (_that) {
case _SignInCodeRequest() when $default != null:
return $default(_that.maskedPhone,_that.expiresAt,_that.resendAfterSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SignInCodeRequest implements SignInCodeRequest {
  const _SignInCodeRequest({required this.maskedPhone, @JsonKey(fromJson: localDateTime) required this.expiresAt, required this.resendAfterSeconds});
  factory _SignInCodeRequest.fromJson(Map<String, dynamic> json) => _$SignInCodeRequestFromJson(json);

@override final  String maskedPhone;
@override@JsonKey(fromJson: localDateTime) final  DateTime expiresAt;
@override final  int resendAfterSeconds;

/// Create a copy of SignInCodeRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignInCodeRequestCopyWith<_SignInCodeRequest> get copyWith => __$SignInCodeRequestCopyWithImpl<_SignInCodeRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SignInCodeRequestToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignInCodeRequest&&(identical(other.maskedPhone, maskedPhone) || other.maskedPhone == maskedPhone)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.resendAfterSeconds, resendAfterSeconds) || other.resendAfterSeconds == resendAfterSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,maskedPhone,expiresAt,resendAfterSeconds);
}

@override
String toString() {
    return 'SignInCodeRequest(maskedPhone: $maskedPhone, expiresAt: $expiresAt, resendAfterSeconds: $resendAfterSeconds)';
}


}

/// @nodoc
abstract mixin class _$SignInCodeRequestCopyWith<$Res> implements $SignInCodeRequestCopyWith<$Res> {
  factory _$SignInCodeRequestCopyWith(_SignInCodeRequest value, $Res Function(_SignInCodeRequest) _then) = __$SignInCodeRequestCopyWithImpl;
@override @useResult
$Res call({
 String maskedPhone,@JsonKey(fromJson: localDateTime) DateTime expiresAt, int resendAfterSeconds
});




}
/// @nodoc
class __$SignInCodeRequestCopyWithImpl<$Res>
    implements _$SignInCodeRequestCopyWith<$Res> {
  __$SignInCodeRequestCopyWithImpl(this._self, this._then);

  final _SignInCodeRequest _self;
  final $Res Function(_SignInCodeRequest) _then;

/// Create a copy of SignInCodeRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maskedPhone = null,Object? expiresAt = null,Object? resendAfterSeconds = null,}) {
  return _then(_SignInCodeRequest(
maskedPhone: null == maskedPhone ? _self.maskedPhone : maskedPhone // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,resendAfterSeconds: null == resendAfterSeconds ? _self.resendAfterSeconds : resendAfterSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
