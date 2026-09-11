// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trips_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TripsState {

 List<Booking> get bookings; PageMeta get page; bool get isLoadingMore; String? get loadMoreError;
/// Create a copy of TripsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripsStateCopyWith<TripsState> get copyWith => _$TripsStateCopyWithImpl<TripsState>(this as TripsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TripsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TripsState&&const DeepCollectionEquality().equals(other.bookings, _this.bookings)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.isLoadingMore, _this.isLoadingMore) || other.isLoadingMore == _this.isLoadingMore)&&(identical(other.loadMoreError, _this.loadMoreError) || other.loadMoreError == _this.loadMoreError));
}


@override
int get hashCode {
  final _this = this as TripsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.bookings),_this.page,_this.isLoadingMore,_this.loadMoreError);
}

@override
String toString() {
  final _this = this as TripsState;
  return 'TripsState(bookings: ${_this.bookings}, page: ${_this.page}, isLoadingMore: ${_this.isLoadingMore}, loadMoreError: ${_this.loadMoreError})';
}


}

/// @nodoc
abstract mixin class $TripsStateCopyWith<$Res>  {
  factory $TripsStateCopyWith(TripsState value, $Res Function(TripsState) _then) = _$TripsStateCopyWithImpl;
@useResult
$Res call({
 List<Booking> bookings, PageMeta page, bool isLoadingMore, String? loadMoreError
});


$PageMetaCopyWith<$Res> get page;

}
/// @nodoc
class _$TripsStateCopyWithImpl<$Res>
    implements $TripsStateCopyWith<$Res> {
  _$TripsStateCopyWithImpl(this._self, this._then);

  final TripsState _self;
  final $Res Function(TripsState) _then;

/// Create a copy of TripsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookings = null,Object? page = null,Object? isLoadingMore = null,Object? loadMoreError = freezed,}) {
  return _then(TripsState(
bookings: null == bookings ? _self.bookings : bookings // ignore: cast_nullable_to_non_nullable
as List<Booking>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as PageMeta,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreError: freezed == loadMoreError ? _self.loadMoreError : loadMoreError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TripsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageMetaCopyWith<$Res> get page {
  
  return $PageMetaCopyWith<$Res>(_self.page, (value) {
    return _then(_self.copyWith(page: value));
  });
}
}


/// Adds pattern-matching-related methods to [TripsState].
extension TripsStatePatterns on TripsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TripsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TripsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TripsState value)  $default,){
final _that = this;
switch (_that) {
case _TripsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TripsState value)?  $default,){
final _that = this;
switch (_that) {
case _TripsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Booking> bookings,  PageMeta page,  bool isLoadingMore,  String? loadMoreError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TripsState() when $default != null:
return $default(_that.bookings,_that.page,_that.isLoadingMore,_that.loadMoreError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Booking> bookings,  PageMeta page,  bool isLoadingMore,  String? loadMoreError)  $default,) {final _that = this;
switch (_that) {
case _TripsState():
return $default(_that.bookings,_that.page,_that.isLoadingMore,_that.loadMoreError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Booking> bookings,  PageMeta page,  bool isLoadingMore,  String? loadMoreError)?  $default,) {final _that = this;
switch (_that) {
case _TripsState() when $default != null:
return $default(_that.bookings,_that.page,_that.isLoadingMore,_that.loadMoreError);case _:
  return null;

}
}

}

/// @nodoc


class _TripsState extends TripsState {
  const _TripsState({required  List<Booking> bookings, required this.page, this.isLoadingMore = false, this.loadMoreError}): _bookings = bookings,super._();
  

 final  List<Booking> _bookings;
@override List<Booking> get bookings {
  if (_bookings is EqualUnmodifiableListView) return _bookings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookings);
}

@override final  PageMeta page;
@override@JsonKey() final  bool isLoadingMore;
@override final  String? loadMoreError;

/// Create a copy of TripsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripsStateCopyWith<_TripsState> get copyWith => __$TripsStateCopyWithImpl<_TripsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TripsState&&const DeepCollectionEquality().equals(other.bookings, _bookings)&&(identical(other.page, page) || other.page == page)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.loadMoreError, loadMoreError) || other.loadMoreError == loadMoreError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_bookings),page,isLoadingMore,loadMoreError);
}

@override
String toString() {
    return 'TripsState(bookings: $bookings, page: $page, isLoadingMore: $isLoadingMore, loadMoreError: $loadMoreError)';
}


}

/// @nodoc
abstract mixin class _$TripsStateCopyWith<$Res> implements $TripsStateCopyWith<$Res> {
  factory _$TripsStateCopyWith(_TripsState value, $Res Function(_TripsState) _then) = __$TripsStateCopyWithImpl;
@override @useResult
$Res call({
 List<Booking> bookings, PageMeta page, bool isLoadingMore, String? loadMoreError
});


@override $PageMetaCopyWith<$Res> get page;

}
/// @nodoc
class __$TripsStateCopyWithImpl<$Res>
    implements _$TripsStateCopyWith<$Res> {
  __$TripsStateCopyWithImpl(this._self, this._then);

  final _TripsState _self;
  final $Res Function(_TripsState) _then;

/// Create a copy of TripsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookings = null,Object? page = null,Object? isLoadingMore = null,Object? loadMoreError = freezed,}) {
  return _then(_TripsState(
bookings: null == bookings ? _self._bookings : bookings // ignore: cast_nullable_to_non_nullable
as List<Booking>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as PageMeta,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreError: freezed == loadMoreError ? _self.loadMoreError : loadMoreError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TripsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageMetaCopyWith<$Res> get page {
  
  return $PageMetaCopyWith<$Res>(_self.page, (value) {
    return _then(_self.copyWith(page: value));
  });
}
}

// dart format on
