// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationUpdate {

 double get lat; double get lng; int get etaMinutes;
/// Create a copy of LocationUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationUpdateCopyWith<LocationUpdate> get copyWith => _$LocationUpdateCopyWithImpl<LocationUpdate>(this as LocationUpdate, _$identity);

  /// Serializes this LocationUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationUpdate&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.etaMinutes, etaMinutes) || other.etaMinutes == etaMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lat,lng,etaMinutes);

@override
String toString() {
  return 'LocationUpdate(lat: $lat, lng: $lng, etaMinutes: $etaMinutes)';
}


}

/// @nodoc
abstract mixin class $LocationUpdateCopyWith<$Res>  {
  factory $LocationUpdateCopyWith(LocationUpdate value, $Res Function(LocationUpdate) _then) = _$LocationUpdateCopyWithImpl;
@useResult
$Res call({
 double lat, double lng, int etaMinutes
});




}
/// @nodoc
class _$LocationUpdateCopyWithImpl<$Res>
    implements $LocationUpdateCopyWith<$Res> {
  _$LocationUpdateCopyWithImpl(this._self, this._then);

  final LocationUpdate _self;
  final $Res Function(LocationUpdate) _then;

/// Create a copy of LocationUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lat = null,Object? lng = null,Object? etaMinutes = null,}) {
  return _then(_self.copyWith(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,etaMinutes: null == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationUpdate].
extension LocationUpdatePatterns on LocationUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationUpdate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationUpdate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationUpdate value)  $default,){
final _that = this;
switch (_that) {
case _LocationUpdate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationUpdate value)?  $default,){
final _that = this;
switch (_that) {
case _LocationUpdate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double lat,  double lng,  int etaMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationUpdate() when $default != null:
return $default(_that.lat,_that.lng,_that.etaMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double lat,  double lng,  int etaMinutes)  $default,) {final _that = this;
switch (_that) {
case _LocationUpdate():
return $default(_that.lat,_that.lng,_that.etaMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double lat,  double lng,  int etaMinutes)?  $default,) {final _that = this;
switch (_that) {
case _LocationUpdate() when $default != null:
return $default(_that.lat,_that.lng,_that.etaMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocationUpdate implements LocationUpdate {
  const _LocationUpdate({required this.lat, required this.lng, required this.etaMinutes});
  factory _LocationUpdate.fromJson(Map<String, dynamic> json) => _$LocationUpdateFromJson(json);

@override final  double lat;
@override final  double lng;
@override final  int etaMinutes;

/// Create a copy of LocationUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationUpdateCopyWith<_LocationUpdate> get copyWith => __$LocationUpdateCopyWithImpl<_LocationUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationUpdate&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.etaMinutes, etaMinutes) || other.etaMinutes == etaMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lat,lng,etaMinutes);

@override
String toString() {
  return 'LocationUpdate(lat: $lat, lng: $lng, etaMinutes: $etaMinutes)';
}


}

/// @nodoc
abstract mixin class _$LocationUpdateCopyWith<$Res> implements $LocationUpdateCopyWith<$Res> {
  factory _$LocationUpdateCopyWith(_LocationUpdate value, $Res Function(_LocationUpdate) _then) = __$LocationUpdateCopyWithImpl;
@override @useResult
$Res call({
 double lat, double lng, int etaMinutes
});




}
/// @nodoc
class __$LocationUpdateCopyWithImpl<$Res>
    implements _$LocationUpdateCopyWith<$Res> {
  __$LocationUpdateCopyWithImpl(this._self, this._then);

  final _LocationUpdate _self;
  final $Res Function(_LocationUpdate) _then;

/// Create a copy of LocationUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lat = null,Object? lng = null,Object? etaMinutes = null,}) {
  return _then(_LocationUpdate(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,etaMinutes: null == etaMinutes ? _self.etaMinutes : etaMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
