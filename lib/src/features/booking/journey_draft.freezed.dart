// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'journey_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JourneyDraft {

 PlaceSelection get pickup; PlaceSelection get dropoff; List<PlaceSelection> get via; DateTime? get pickupDate; TimeOfDay? get pickupTime; bool get isReturn; DateTime? get returnDate; TimeOfDay? get returnTime; int get passengerCount; int get luggageCount; String? get outboundFlightNumber; String? get outboundTerminal; String? get returnFlightNumber; String? get returnTerminal; String? get vehicleCategorySlug;
/// Create a copy of JourneyDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JourneyDraftCopyWith<JourneyDraft> get copyWith => _$JourneyDraftCopyWithImpl<JourneyDraft>(this as JourneyDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as JourneyDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JourneyDraft&&(identical(other.pickup, _this.pickup) || other.pickup == _this.pickup)&&(identical(other.dropoff, _this.dropoff) || other.dropoff == _this.dropoff)&&const DeepCollectionEquality().equals(other.via, _this.via)&&(identical(other.pickupDate, _this.pickupDate) || other.pickupDate == _this.pickupDate)&&(identical(other.pickupTime, _this.pickupTime) || other.pickupTime == _this.pickupTime)&&(identical(other.isReturn, _this.isReturn) || other.isReturn == _this.isReturn)&&(identical(other.returnDate, _this.returnDate) || other.returnDate == _this.returnDate)&&(identical(other.returnTime, _this.returnTime) || other.returnTime == _this.returnTime)&&(identical(other.passengerCount, _this.passengerCount) || other.passengerCount == _this.passengerCount)&&(identical(other.luggageCount, _this.luggageCount) || other.luggageCount == _this.luggageCount)&&(identical(other.outboundFlightNumber, _this.outboundFlightNumber) || other.outboundFlightNumber == _this.outboundFlightNumber)&&(identical(other.outboundTerminal, _this.outboundTerminal) || other.outboundTerminal == _this.outboundTerminal)&&(identical(other.returnFlightNumber, _this.returnFlightNumber) || other.returnFlightNumber == _this.returnFlightNumber)&&(identical(other.returnTerminal, _this.returnTerminal) || other.returnTerminal == _this.returnTerminal)&&(identical(other.vehicleCategorySlug, _this.vehicleCategorySlug) || other.vehicleCategorySlug == _this.vehicleCategorySlug));
}


@override
int get hashCode {
  final _this = this as JourneyDraft;
  return Object.hash(runtimeType,_this.pickup,_this.dropoff,const DeepCollectionEquality().hash(_this.via),_this.pickupDate,_this.pickupTime,_this.isReturn,_this.returnDate,_this.returnTime,_this.passengerCount,_this.luggageCount,_this.outboundFlightNumber,_this.outboundTerminal,_this.returnFlightNumber,_this.returnTerminal,_this.vehicleCategorySlug);
}

@override
String toString() {
  final _this = this as JourneyDraft;
  return 'JourneyDraft(pickup: ${_this.pickup}, dropoff: ${_this.dropoff}, via: ${_this.via}, pickupDate: ${_this.pickupDate}, pickupTime: ${_this.pickupTime}, isReturn: ${_this.isReturn}, returnDate: ${_this.returnDate}, returnTime: ${_this.returnTime}, passengerCount: ${_this.passengerCount}, luggageCount: ${_this.luggageCount}, outboundFlightNumber: ${_this.outboundFlightNumber}, outboundTerminal: ${_this.outboundTerminal}, returnFlightNumber: ${_this.returnFlightNumber}, returnTerminal: ${_this.returnTerminal}, vehicleCategorySlug: ${_this.vehicleCategorySlug})';
}


}

/// @nodoc
abstract mixin class $JourneyDraftCopyWith<$Res>  {
  factory $JourneyDraftCopyWith(JourneyDraft value, $Res Function(JourneyDraft) _then) = _$JourneyDraftCopyWithImpl;
@useResult
$Res call({
 PlaceSelection pickup, PlaceSelection dropoff, List<PlaceSelection> via, DateTime? pickupDate, TimeOfDay? pickupTime, bool isReturn, DateTime? returnDate, TimeOfDay? returnTime, int passengerCount, int luggageCount, String? outboundFlightNumber, String? outboundTerminal, String? returnFlightNumber, String? returnTerminal, String? vehicleCategorySlug
});


$PlaceSelectionCopyWith<$Res> get pickup;$PlaceSelectionCopyWith<$Res> get dropoff;

}
/// @nodoc
class _$JourneyDraftCopyWithImpl<$Res>
    implements $JourneyDraftCopyWith<$Res> {
  _$JourneyDraftCopyWithImpl(this._self, this._then);

  final JourneyDraft _self;
  final $Res Function(JourneyDraft) _then;

/// Create a copy of JourneyDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pickup = null,Object? dropoff = null,Object? via = null,Object? pickupDate = freezed,Object? pickupTime = freezed,Object? isReturn = null,Object? returnDate = freezed,Object? returnTime = freezed,Object? passengerCount = null,Object? luggageCount = null,Object? outboundFlightNumber = freezed,Object? outboundTerminal = freezed,Object? returnFlightNumber = freezed,Object? returnTerminal = freezed,Object? vehicleCategorySlug = freezed,}) {
  return _then(JourneyDraft(
pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as PlaceSelection,dropoff: null == dropoff ? _self.dropoff : dropoff // ignore: cast_nullable_to_non_nullable
as PlaceSelection,via: null == via ? _self.via : via // ignore: cast_nullable_to_non_nullable
as List<PlaceSelection>,pickupDate: freezed == pickupDate ? _self.pickupDate : pickupDate // ignore: cast_nullable_to_non_nullable
as DateTime?,pickupTime: freezed == pickupTime ? _self.pickupTime : pickupTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,isReturn: null == isReturn ? _self.isReturn : isReturn // ignore: cast_nullable_to_non_nullable
as bool,returnDate: freezed == returnDate ? _self.returnDate : returnDate // ignore: cast_nullable_to_non_nullable
as DateTime?,returnTime: freezed == returnTime ? _self.returnTime : returnTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,passengerCount: null == passengerCount ? _self.passengerCount : passengerCount // ignore: cast_nullable_to_non_nullable
as int,luggageCount: null == luggageCount ? _self.luggageCount : luggageCount // ignore: cast_nullable_to_non_nullable
as int,outboundFlightNumber: freezed == outboundFlightNumber ? _self.outboundFlightNumber : outboundFlightNumber // ignore: cast_nullable_to_non_nullable
as String?,outboundTerminal: freezed == outboundTerminal ? _self.outboundTerminal : outboundTerminal // ignore: cast_nullable_to_non_nullable
as String?,returnFlightNumber: freezed == returnFlightNumber ? _self.returnFlightNumber : returnFlightNumber // ignore: cast_nullable_to_non_nullable
as String?,returnTerminal: freezed == returnTerminal ? _self.returnTerminal : returnTerminal // ignore: cast_nullable_to_non_nullable
as String?,vehicleCategorySlug: freezed == vehicleCategorySlug ? _self.vehicleCategorySlug : vehicleCategorySlug // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of JourneyDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceSelectionCopyWith<$Res> get pickup {
  
  return $PlaceSelectionCopyWith<$Res>(_self.pickup, (value) {
    return _then(_self.copyWith(pickup: value));
  });
}/// Create a copy of JourneyDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceSelectionCopyWith<$Res> get dropoff {
  
  return $PlaceSelectionCopyWith<$Res>(_self.dropoff, (value) {
    return _then(_self.copyWith(dropoff: value));
  });
}
}


/// Adds pattern-matching-related methods to [JourneyDraft].
extension JourneyDraftPatterns on JourneyDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JourneyDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JourneyDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JourneyDraft value)  $default,){
final _that = this;
switch (_that) {
case _JourneyDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JourneyDraft value)?  $default,){
final _that = this;
switch (_that) {
case _JourneyDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlaceSelection pickup,  PlaceSelection dropoff,  List<PlaceSelection> via,  DateTime? pickupDate,  TimeOfDay? pickupTime,  bool isReturn,  DateTime? returnDate,  TimeOfDay? returnTime,  int passengerCount,  int luggageCount,  String? outboundFlightNumber,  String? outboundTerminal,  String? returnFlightNumber,  String? returnTerminal,  String? vehicleCategorySlug)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JourneyDraft() when $default != null:
return $default(_that.pickup,_that.dropoff,_that.via,_that.pickupDate,_that.pickupTime,_that.isReturn,_that.returnDate,_that.returnTime,_that.passengerCount,_that.luggageCount,_that.outboundFlightNumber,_that.outboundTerminal,_that.returnFlightNumber,_that.returnTerminal,_that.vehicleCategorySlug);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlaceSelection pickup,  PlaceSelection dropoff,  List<PlaceSelection> via,  DateTime? pickupDate,  TimeOfDay? pickupTime,  bool isReturn,  DateTime? returnDate,  TimeOfDay? returnTime,  int passengerCount,  int luggageCount,  String? outboundFlightNumber,  String? outboundTerminal,  String? returnFlightNumber,  String? returnTerminal,  String? vehicleCategorySlug)  $default,) {final _that = this;
switch (_that) {
case _JourneyDraft():
return $default(_that.pickup,_that.dropoff,_that.via,_that.pickupDate,_that.pickupTime,_that.isReturn,_that.returnDate,_that.returnTime,_that.passengerCount,_that.luggageCount,_that.outboundFlightNumber,_that.outboundTerminal,_that.returnFlightNumber,_that.returnTerminal,_that.vehicleCategorySlug);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlaceSelection pickup,  PlaceSelection dropoff,  List<PlaceSelection> via,  DateTime? pickupDate,  TimeOfDay? pickupTime,  bool isReturn,  DateTime? returnDate,  TimeOfDay? returnTime,  int passengerCount,  int luggageCount,  String? outboundFlightNumber,  String? outboundTerminal,  String? returnFlightNumber,  String? returnTerminal,  String? vehicleCategorySlug)?  $default,) {final _that = this;
switch (_that) {
case _JourneyDraft() when $default != null:
return $default(_that.pickup,_that.dropoff,_that.via,_that.pickupDate,_that.pickupTime,_that.isReturn,_that.returnDate,_that.returnTime,_that.passengerCount,_that.luggageCount,_that.outboundFlightNumber,_that.outboundTerminal,_that.returnFlightNumber,_that.returnTerminal,_that.vehicleCategorySlug);case _:
  return null;

}
}

}

/// @nodoc


class _JourneyDraft extends JourneyDraft {
  const _JourneyDraft({this.pickup = PlaceSelection.empty, this.dropoff = PlaceSelection.empty,  List<PlaceSelection> via = const [], this.pickupDate, this.pickupTime, this.isReturn = false, this.returnDate, this.returnTime, this.passengerCount = 1, this.luggageCount = 0, this.outboundFlightNumber, this.outboundTerminal, this.returnFlightNumber, this.returnTerminal, this.vehicleCategorySlug}): _via = via,super._();
  

@override@JsonKey() final  PlaceSelection pickup;
@override@JsonKey() final  PlaceSelection dropoff;
 final  List<PlaceSelection> _via;
@override@JsonKey() List<PlaceSelection> get via {
  if (_via is EqualUnmodifiableListView) return _via;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_via);
}

@override final  DateTime? pickupDate;
@override final  TimeOfDay? pickupTime;
@override@JsonKey() final  bool isReturn;
@override final  DateTime? returnDate;
@override final  TimeOfDay? returnTime;
@override@JsonKey() final  int passengerCount;
@override@JsonKey() final  int luggageCount;
@override final  String? outboundFlightNumber;
@override final  String? outboundTerminal;
@override final  String? returnFlightNumber;
@override final  String? returnTerminal;
@override final  String? vehicleCategorySlug;

/// Create a copy of JourneyDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JourneyDraftCopyWith<_JourneyDraft> get copyWith => __$JourneyDraftCopyWithImpl<_JourneyDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _JourneyDraft&&(identical(other.pickup, pickup) || other.pickup == pickup)&&(identical(other.dropoff, dropoff) || other.dropoff == dropoff)&&const DeepCollectionEquality().equals(other.via, _via)&&(identical(other.pickupDate, pickupDate) || other.pickupDate == pickupDate)&&(identical(other.pickupTime, pickupTime) || other.pickupTime == pickupTime)&&(identical(other.isReturn, isReturn) || other.isReturn == isReturn)&&(identical(other.returnDate, returnDate) || other.returnDate == returnDate)&&(identical(other.returnTime, returnTime) || other.returnTime == returnTime)&&(identical(other.passengerCount, passengerCount) || other.passengerCount == passengerCount)&&(identical(other.luggageCount, luggageCount) || other.luggageCount == luggageCount)&&(identical(other.outboundFlightNumber, outboundFlightNumber) || other.outboundFlightNumber == outboundFlightNumber)&&(identical(other.outboundTerminal, outboundTerminal) || other.outboundTerminal == outboundTerminal)&&(identical(other.returnFlightNumber, returnFlightNumber) || other.returnFlightNumber == returnFlightNumber)&&(identical(other.returnTerminal, returnTerminal) || other.returnTerminal == returnTerminal)&&(identical(other.vehicleCategorySlug, vehicleCategorySlug) || other.vehicleCategorySlug == vehicleCategorySlug));
}


@override
int get hashCode {
    return Object.hash(runtimeType,pickup,dropoff,const DeepCollectionEquality().hash(_via),pickupDate,pickupTime,isReturn,returnDate,returnTime,passengerCount,luggageCount,outboundFlightNumber,outboundTerminal,returnFlightNumber,returnTerminal,vehicleCategorySlug);
}

@override
String toString() {
    return 'JourneyDraft(pickup: $pickup, dropoff: $dropoff, via: $via, pickupDate: $pickupDate, pickupTime: $pickupTime, isReturn: $isReturn, returnDate: $returnDate, returnTime: $returnTime, passengerCount: $passengerCount, luggageCount: $luggageCount, outboundFlightNumber: $outboundFlightNumber, outboundTerminal: $outboundTerminal, returnFlightNumber: $returnFlightNumber, returnTerminal: $returnTerminal, vehicleCategorySlug: $vehicleCategorySlug)';
}


}

/// @nodoc
abstract mixin class _$JourneyDraftCopyWith<$Res> implements $JourneyDraftCopyWith<$Res> {
  factory _$JourneyDraftCopyWith(_JourneyDraft value, $Res Function(_JourneyDraft) _then) = __$JourneyDraftCopyWithImpl;
@override @useResult
$Res call({
 PlaceSelection pickup, PlaceSelection dropoff, List<PlaceSelection> via, DateTime? pickupDate, TimeOfDay? pickupTime, bool isReturn, DateTime? returnDate, TimeOfDay? returnTime, int passengerCount, int luggageCount, String? outboundFlightNumber, String? outboundTerminal, String? returnFlightNumber, String? returnTerminal, String? vehicleCategorySlug
});


@override $PlaceSelectionCopyWith<$Res> get pickup;@override $PlaceSelectionCopyWith<$Res> get dropoff;

}
/// @nodoc
class __$JourneyDraftCopyWithImpl<$Res>
    implements _$JourneyDraftCopyWith<$Res> {
  __$JourneyDraftCopyWithImpl(this._self, this._then);

  final _JourneyDraft _self;
  final $Res Function(_JourneyDraft) _then;

/// Create a copy of JourneyDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pickup = null,Object? dropoff = null,Object? via = null,Object? pickupDate = freezed,Object? pickupTime = freezed,Object? isReturn = null,Object? returnDate = freezed,Object? returnTime = freezed,Object? passengerCount = null,Object? luggageCount = null,Object? outboundFlightNumber = freezed,Object? outboundTerminal = freezed,Object? returnFlightNumber = freezed,Object? returnTerminal = freezed,Object? vehicleCategorySlug = freezed,}) {
  return _then(_JourneyDraft(
pickup: null == pickup ? _self.pickup : pickup // ignore: cast_nullable_to_non_nullable
as PlaceSelection,dropoff: null == dropoff ? _self.dropoff : dropoff // ignore: cast_nullable_to_non_nullable
as PlaceSelection,via: null == via ? _self._via : via // ignore: cast_nullable_to_non_nullable
as List<PlaceSelection>,pickupDate: freezed == pickupDate ? _self.pickupDate : pickupDate // ignore: cast_nullable_to_non_nullable
as DateTime?,pickupTime: freezed == pickupTime ? _self.pickupTime : pickupTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,isReturn: null == isReturn ? _self.isReturn : isReturn // ignore: cast_nullable_to_non_nullable
as bool,returnDate: freezed == returnDate ? _self.returnDate : returnDate // ignore: cast_nullable_to_non_nullable
as DateTime?,returnTime: freezed == returnTime ? _self.returnTime : returnTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,passengerCount: null == passengerCount ? _self.passengerCount : passengerCount // ignore: cast_nullable_to_non_nullable
as int,luggageCount: null == luggageCount ? _self.luggageCount : luggageCount // ignore: cast_nullable_to_non_nullable
as int,outboundFlightNumber: freezed == outboundFlightNumber ? _self.outboundFlightNumber : outboundFlightNumber // ignore: cast_nullable_to_non_nullable
as String?,outboundTerminal: freezed == outboundTerminal ? _self.outboundTerminal : outboundTerminal // ignore: cast_nullable_to_non_nullable
as String?,returnFlightNumber: freezed == returnFlightNumber ? _self.returnFlightNumber : returnFlightNumber // ignore: cast_nullable_to_non_nullable
as String?,returnTerminal: freezed == returnTerminal ? _self.returnTerminal : returnTerminal // ignore: cast_nullable_to_non_nullable
as String?,vehicleCategorySlug: freezed == vehicleCategorySlug ? _self.vehicleCategorySlug : vehicleCategorySlug // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of JourneyDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceSelectionCopyWith<$Res> get pickup {
  
  return $PlaceSelectionCopyWith<$Res>(_self.pickup, (value) {
    return _then(_self.copyWith(pickup: value));
  });
}/// Create a copy of JourneyDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlaceSelectionCopyWith<$Res> get dropoff {
  
  return $PlaceSelectionCopyWith<$Res>(_self.dropoff, (value) {
    return _then(_self.copyWith(dropoff: value));
  });
}
}

// dart format on
