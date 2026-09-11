// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_flow_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookingFlowState {

 JourneyDraft get journey; Quote? get quote; List<VehicleCategory> get vehicles; bool get isQuoting; String? get quoteError; bool get isBooking; String? get bookingError; Map<String, List<String>> get fieldErrors;/// Set once the booking has been created; the confirmation screen reads it.
 Booking? get booking;
/// Create a copy of BookingFlowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingFlowStateCopyWith<BookingFlowState> get copyWith => _$BookingFlowStateCopyWithImpl<BookingFlowState>(this as BookingFlowState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BookingFlowState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingFlowState&&(identical(other.journey, _this.journey) || other.journey == _this.journey)&&(identical(other.quote, _this.quote) || other.quote == _this.quote)&&const DeepCollectionEquality().equals(other.vehicles, _this.vehicles)&&(identical(other.isQuoting, _this.isQuoting) || other.isQuoting == _this.isQuoting)&&(identical(other.quoteError, _this.quoteError) || other.quoteError == _this.quoteError)&&(identical(other.isBooking, _this.isBooking) || other.isBooking == _this.isBooking)&&(identical(other.bookingError, _this.bookingError) || other.bookingError == _this.bookingError)&&const DeepCollectionEquality().equals(other.fieldErrors, _this.fieldErrors)&&(identical(other.booking, _this.booking) || other.booking == _this.booking));
}


@override
int get hashCode {
  final _this = this as BookingFlowState;
  return Object.hash(runtimeType,_this.journey,_this.quote,const DeepCollectionEquality().hash(_this.vehicles),_this.isQuoting,_this.quoteError,_this.isBooking,_this.bookingError,const DeepCollectionEquality().hash(_this.fieldErrors),_this.booking);
}

@override
String toString() {
  final _this = this as BookingFlowState;
  return 'BookingFlowState(journey: ${_this.journey}, quote: ${_this.quote}, vehicles: ${_this.vehicles}, isQuoting: ${_this.isQuoting}, quoteError: ${_this.quoteError}, isBooking: ${_this.isBooking}, bookingError: ${_this.bookingError}, fieldErrors: ${_this.fieldErrors}, booking: ${_this.booking})';
}


}

/// @nodoc
abstract mixin class $BookingFlowStateCopyWith<$Res>  {
  factory $BookingFlowStateCopyWith(BookingFlowState value, $Res Function(BookingFlowState) _then) = _$BookingFlowStateCopyWithImpl;
@useResult
$Res call({
 JourneyDraft journey, Quote? quote, List<VehicleCategory> vehicles, bool isQuoting, String? quoteError, bool isBooking, String? bookingError, Map<String, List<String>> fieldErrors, Booking? booking
});


$JourneyDraftCopyWith<$Res> get journey;$QuoteCopyWith<$Res>? get quote;$BookingCopyWith<$Res>? get booking;

}
/// @nodoc
class _$BookingFlowStateCopyWithImpl<$Res>
    implements $BookingFlowStateCopyWith<$Res> {
  _$BookingFlowStateCopyWithImpl(this._self, this._then);

  final BookingFlowState _self;
  final $Res Function(BookingFlowState) _then;

/// Create a copy of BookingFlowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? journey = null,Object? quote = freezed,Object? vehicles = null,Object? isQuoting = null,Object? quoteError = freezed,Object? isBooking = null,Object? bookingError = freezed,Object? fieldErrors = null,Object? booking = freezed,}) {
  return _then(BookingFlowState(
journey: null == journey ? _self.journey : journey // ignore: cast_nullable_to_non_nullable
as JourneyDraft,quote: freezed == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as Quote?,vehicles: null == vehicles ? _self.vehicles : vehicles // ignore: cast_nullable_to_non_nullable
as List<VehicleCategory>,isQuoting: null == isQuoting ? _self.isQuoting : isQuoting // ignore: cast_nullable_to_non_nullable
as bool,quoteError: freezed == quoteError ? _self.quoteError : quoteError // ignore: cast_nullable_to_non_nullable
as String?,isBooking: null == isBooking ? _self.isBooking : isBooking // ignore: cast_nullable_to_non_nullable
as bool,bookingError: freezed == bookingError ? _self.bookingError : bookingError // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self.fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,booking: freezed == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as Booking?,
  ));
}
/// Create a copy of BookingFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JourneyDraftCopyWith<$Res> get journey {
  
  return $JourneyDraftCopyWith<$Res>(_self.journey, (value) {
    return _then(_self.copyWith(journey: value));
  });
}/// Create a copy of BookingFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuoteCopyWith<$Res>? get quote {
    if (_self.quote == null) {
    return null;
  }

  return $QuoteCopyWith<$Res>(_self.quote!, (value) {
    return _then(_self.copyWith(quote: value));
  });
}/// Create a copy of BookingFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingCopyWith<$Res>? get booking {
    if (_self.booking == null) {
    return null;
  }

  return $BookingCopyWith<$Res>(_self.booking!, (value) {
    return _then(_self.copyWith(booking: value));
  });
}
}


/// Adds pattern-matching-related methods to [BookingFlowState].
extension BookingFlowStatePatterns on BookingFlowState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingFlowState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingFlowState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingFlowState value)  $default,){
final _that = this;
switch (_that) {
case _BookingFlowState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingFlowState value)?  $default,){
final _that = this;
switch (_that) {
case _BookingFlowState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( JourneyDraft journey,  Quote? quote,  List<VehicleCategory> vehicles,  bool isQuoting,  String? quoteError,  bool isBooking,  String? bookingError,  Map<String, List<String>> fieldErrors,  Booking? booking)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingFlowState() when $default != null:
return $default(_that.journey,_that.quote,_that.vehicles,_that.isQuoting,_that.quoteError,_that.isBooking,_that.bookingError,_that.fieldErrors,_that.booking);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( JourneyDraft journey,  Quote? quote,  List<VehicleCategory> vehicles,  bool isQuoting,  String? quoteError,  bool isBooking,  String? bookingError,  Map<String, List<String>> fieldErrors,  Booking? booking)  $default,) {final _that = this;
switch (_that) {
case _BookingFlowState():
return $default(_that.journey,_that.quote,_that.vehicles,_that.isQuoting,_that.quoteError,_that.isBooking,_that.bookingError,_that.fieldErrors,_that.booking);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( JourneyDraft journey,  Quote? quote,  List<VehicleCategory> vehicles,  bool isQuoting,  String? quoteError,  bool isBooking,  String? bookingError,  Map<String, List<String>> fieldErrors,  Booking? booking)?  $default,) {final _that = this;
switch (_that) {
case _BookingFlowState() when $default != null:
return $default(_that.journey,_that.quote,_that.vehicles,_that.isQuoting,_that.quoteError,_that.isBooking,_that.bookingError,_that.fieldErrors,_that.booking);case _:
  return null;

}
}

}

/// @nodoc


class _BookingFlowState extends BookingFlowState {
  const _BookingFlowState({this.journey = const JourneyDraft(), this.quote,  List<VehicleCategory> vehicles = const [], this.isQuoting = false, this.quoteError, this.isBooking = false, this.bookingError,  Map<String, List<String>> fieldErrors = const {}, this.booking}): _vehicles = vehicles,_fieldErrors = fieldErrors,super._();
  

@override@JsonKey() final  JourneyDraft journey;
@override final  Quote? quote;
 final  List<VehicleCategory> _vehicles;
@override@JsonKey() List<VehicleCategory> get vehicles {
  if (_vehicles is EqualUnmodifiableListView) return _vehicles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vehicles);
}

@override@JsonKey() final  bool isQuoting;
@override final  String? quoteError;
@override@JsonKey() final  bool isBooking;
@override final  String? bookingError;
 final  Map<String, List<String>> _fieldErrors;
@override@JsonKey() Map<String, List<String>> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}

/// Set once the booking has been created; the confirmation screen reads it.
@override final  Booking? booking;

/// Create a copy of BookingFlowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingFlowStateCopyWith<_BookingFlowState> get copyWith => __$BookingFlowStateCopyWithImpl<_BookingFlowState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingFlowState&&(identical(other.journey, journey) || other.journey == journey)&&(identical(other.quote, quote) || other.quote == quote)&&const DeepCollectionEquality().equals(other.vehicles, _vehicles)&&(identical(other.isQuoting, isQuoting) || other.isQuoting == isQuoting)&&(identical(other.quoteError, quoteError) || other.quoteError == quoteError)&&(identical(other.isBooking, isBooking) || other.isBooking == isBooking)&&(identical(other.bookingError, bookingError) || other.bookingError == bookingError)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors)&&(identical(other.booking, booking) || other.booking == booking));
}


@override
int get hashCode {
    return Object.hash(runtimeType,journey,quote,const DeepCollectionEquality().hash(_vehicles),isQuoting,quoteError,isBooking,bookingError,const DeepCollectionEquality().hash(_fieldErrors),booking);
}

@override
String toString() {
    return 'BookingFlowState(journey: $journey, quote: $quote, vehicles: $vehicles, isQuoting: $isQuoting, quoteError: $quoteError, isBooking: $isBooking, bookingError: $bookingError, fieldErrors: $fieldErrors, booking: $booking)';
}


}

/// @nodoc
abstract mixin class _$BookingFlowStateCopyWith<$Res> implements $BookingFlowStateCopyWith<$Res> {
  factory _$BookingFlowStateCopyWith(_BookingFlowState value, $Res Function(_BookingFlowState) _then) = __$BookingFlowStateCopyWithImpl;
@override @useResult
$Res call({
 JourneyDraft journey, Quote? quote, List<VehicleCategory> vehicles, bool isQuoting, String? quoteError, bool isBooking, String? bookingError, Map<String, List<String>> fieldErrors, Booking? booking
});


@override $JourneyDraftCopyWith<$Res> get journey;@override $QuoteCopyWith<$Res>? get quote;@override $BookingCopyWith<$Res>? get booking;

}
/// @nodoc
class __$BookingFlowStateCopyWithImpl<$Res>
    implements _$BookingFlowStateCopyWith<$Res> {
  __$BookingFlowStateCopyWithImpl(this._self, this._then);

  final _BookingFlowState _self;
  final $Res Function(_BookingFlowState) _then;

/// Create a copy of BookingFlowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? journey = null,Object? quote = freezed,Object? vehicles = null,Object? isQuoting = null,Object? quoteError = freezed,Object? isBooking = null,Object? bookingError = freezed,Object? fieldErrors = null,Object? booking = freezed,}) {
  return _then(_BookingFlowState(
journey: null == journey ? _self.journey : journey // ignore: cast_nullable_to_non_nullable
as JourneyDraft,quote: freezed == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as Quote?,vehicles: null == vehicles ? _self._vehicles : vehicles // ignore: cast_nullable_to_non_nullable
as List<VehicleCategory>,isQuoting: null == isQuoting ? _self.isQuoting : isQuoting // ignore: cast_nullable_to_non_nullable
as bool,quoteError: freezed == quoteError ? _self.quoteError : quoteError // ignore: cast_nullable_to_non_nullable
as String?,isBooking: null == isBooking ? _self.isBooking : isBooking // ignore: cast_nullable_to_non_nullable
as bool,bookingError: freezed == bookingError ? _self.bookingError : bookingError // ignore: cast_nullable_to_non_nullable
as String?,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,booking: freezed == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as Booking?,
  ));
}

/// Create a copy of BookingFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JourneyDraftCopyWith<$Res> get journey {
  
  return $JourneyDraftCopyWith<$Res>(_self.journey, (value) {
    return _then(_self.copyWith(journey: value));
  });
}/// Create a copy of BookingFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuoteCopyWith<$Res>? get quote {
    if (_self.quote == null) {
    return null;
  }

  return $QuoteCopyWith<$Res>(_self.quote!, (value) {
    return _then(_self.copyWith(quote: value));
  });
}/// Create a copy of BookingFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BookingCopyWith<$Res>? get booking {
    if (_self.booking == null) {
    return null;
  }

  return $BookingCopyWith<$Res>(_self.booking!, (value) {
    return _then(_self.copyWith(booking: value));
  });
}
}

// dart format on
