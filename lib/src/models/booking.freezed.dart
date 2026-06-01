// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Booking {

 String get id;@JsonKey(name: 'service_id') String get serviceId;@JsonKey(name: 'package_id') String get packageId;@JsonKey(name: 'provider_id') String? get providerId; BookingStatus get status;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'scheduled_at') DateTime? get scheduledAt; PriceBreakdown? get price; Provider? get provider;@JsonKey(name: 'special_instructions') String? get notes;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.price, price) || other.price == price)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,serviceId,packageId,providerId,status,createdAt,scheduledAt,price,provider,notes);

@override
String toString() {
  return 'Booking(id: $id, serviceId: $serviceId, packageId: $packageId, providerId: $providerId, status: $status, createdAt: $createdAt, scheduledAt: $scheduledAt, price: $price, provider: $provider, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'service_id') String serviceId,@JsonKey(name: 'package_id') String packageId,@JsonKey(name: 'provider_id') String? providerId, BookingStatus status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'scheduled_at') DateTime? scheduledAt, PriceBreakdown? price, Provider? provider,@JsonKey(name: 'special_instructions') String? notes
});


$PriceBreakdownCopyWith<$Res>? get price;$ProviderCopyWith<$Res>? get provider;

}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? serviceId = null,Object? packageId = null,Object? providerId = freezed,Object? status = null,Object? createdAt = null,Object? scheduledAt = freezed,Object? price = freezed,Object? provider = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,providerId: freezed == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as PriceBreakdown?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as Provider?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceBreakdownCopyWith<$Res>? get price {
    if (_self.price == null) {
    return null;
  }

  return $PriceBreakdownCopyWith<$Res>(_self.price!, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderCopyWith<$Res>? get provider {
    if (_self.provider == null) {
    return null;
  }

  return $ProviderCopyWith<$Res>(_self.provider!, (value) {
    return _then(_self.copyWith(provider: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'service_id')  String serviceId, @JsonKey(name: 'package_id')  String packageId, @JsonKey(name: 'provider_id')  String? providerId,  BookingStatus status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'scheduled_at')  DateTime? scheduledAt,  PriceBreakdown? price,  Provider? provider, @JsonKey(name: 'special_instructions')  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.serviceId,_that.packageId,_that.providerId,_that.status,_that.createdAt,_that.scheduledAt,_that.price,_that.provider,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'service_id')  String serviceId, @JsonKey(name: 'package_id')  String packageId, @JsonKey(name: 'provider_id')  String? providerId,  BookingStatus status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'scheduled_at')  DateTime? scheduledAt,  PriceBreakdown? price,  Provider? provider, @JsonKey(name: 'special_instructions')  String? notes)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.serviceId,_that.packageId,_that.providerId,_that.status,_that.createdAt,_that.scheduledAt,_that.price,_that.provider,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'service_id')  String serviceId, @JsonKey(name: 'package_id')  String packageId, @JsonKey(name: 'provider_id')  String? providerId,  BookingStatus status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'scheduled_at')  DateTime? scheduledAt,  PriceBreakdown? price,  Provider? provider, @JsonKey(name: 'special_instructions')  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.serviceId,_that.packageId,_that.providerId,_that.status,_that.createdAt,_that.scheduledAt,_that.price,_that.provider,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking implements Booking {
  const _Booking({required this.id, @JsonKey(name: 'service_id') required this.serviceId, @JsonKey(name: 'package_id') required this.packageId, @JsonKey(name: 'provider_id') this.providerId, required this.status, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'scheduled_at') this.scheduledAt, this.price, this.provider, @JsonKey(name: 'special_instructions') this.notes});
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String id;
@override@JsonKey(name: 'service_id') final  String serviceId;
@override@JsonKey(name: 'package_id') final  String packageId;
@override@JsonKey(name: 'provider_id') final  String? providerId;
@override final  BookingStatus status;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'scheduled_at') final  DateTime? scheduledAt;
@override final  PriceBreakdown? price;
@override final  Provider? provider;
@override@JsonKey(name: 'special_instructions') final  String? notes;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.price, price) || other.price == price)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,serviceId,packageId,providerId,status,createdAt,scheduledAt,price,provider,notes);

@override
String toString() {
  return 'Booking(id: $id, serviceId: $serviceId, packageId: $packageId, providerId: $providerId, status: $status, createdAt: $createdAt, scheduledAt: $scheduledAt, price: $price, provider: $provider, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'service_id') String serviceId,@JsonKey(name: 'package_id') String packageId,@JsonKey(name: 'provider_id') String? providerId, BookingStatus status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'scheduled_at') DateTime? scheduledAt, PriceBreakdown? price, Provider? provider,@JsonKey(name: 'special_instructions') String? notes
});


@override $PriceBreakdownCopyWith<$Res>? get price;@override $ProviderCopyWith<$Res>? get provider;

}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? serviceId = null,Object? packageId = null,Object? providerId = freezed,Object? status = null,Object? createdAt = null,Object? scheduledAt = freezed,Object? price = freezed,Object? provider = freezed,Object? notes = freezed,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,providerId: freezed == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as PriceBreakdown?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as Provider?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceBreakdownCopyWith<$Res>? get price {
    if (_self.price == null) {
    return null;
  }

  return $PriceBreakdownCopyWith<$Res>(_self.price!, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderCopyWith<$Res>? get provider {
    if (_self.provider == null) {
    return null;
  }

  return $ProviderCopyWith<$Res>(_self.provider!, (value) {
    return _then(_self.copyWith(provider: value));
  });
}
}

// dart format on
