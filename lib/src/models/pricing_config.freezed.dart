// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pricing_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PricingConfig {

 String? get id;@JsonKey(name: 'service_type') String get serviceType;@JsonKey(name: 'base_rate') double get baseRate;@JsonKey(name: 'mistri_daily_wage') double get mistriDailyWage;@JsonKey(name: 'beldar_daily_wage') double get beldarDailyWage;@JsonKey(name: 'material_coefficient') double get materialCoefficient;@JsonKey(name: 'additional_meta') Map<String, dynamic> get additionalMeta;@JsonKey(name: 'updated_at') String? get updatedAt;@JsonKey(name: 'updated_by') String? get updatedBy;
/// Create a copy of PricingConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PricingConfigCopyWith<PricingConfig> get copyWith => _$PricingConfigCopyWithImpl<PricingConfig>(this as PricingConfig, _$identity);

  /// Serializes this PricingConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PricingConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.baseRate, baseRate) || other.baseRate == baseRate)&&(identical(other.mistriDailyWage, mistriDailyWage) || other.mistriDailyWage == mistriDailyWage)&&(identical(other.beldarDailyWage, beldarDailyWage) || other.beldarDailyWage == beldarDailyWage)&&(identical(other.materialCoefficient, materialCoefficient) || other.materialCoefficient == materialCoefficient)&&const DeepCollectionEquality().equals(other.additionalMeta, additionalMeta)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,serviceType,baseRate,mistriDailyWage,beldarDailyWage,materialCoefficient,const DeepCollectionEquality().hash(additionalMeta),updatedAt,updatedBy);

@override
String toString() {
  return 'PricingConfig(id: $id, serviceType: $serviceType, baseRate: $baseRate, mistriDailyWage: $mistriDailyWage, beldarDailyWage: $beldarDailyWage, materialCoefficient: $materialCoefficient, additionalMeta: $additionalMeta, updatedAt: $updatedAt, updatedBy: $updatedBy)';
}


}

/// @nodoc
abstract mixin class $PricingConfigCopyWith<$Res>  {
  factory $PricingConfigCopyWith(PricingConfig value, $Res Function(PricingConfig) _then) = _$PricingConfigCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'service_type') String serviceType,@JsonKey(name: 'base_rate') double baseRate,@JsonKey(name: 'mistri_daily_wage') double mistriDailyWage,@JsonKey(name: 'beldar_daily_wage') double beldarDailyWage,@JsonKey(name: 'material_coefficient') double materialCoefficient,@JsonKey(name: 'additional_meta') Map<String, dynamic> additionalMeta,@JsonKey(name: 'updated_at') String? updatedAt,@JsonKey(name: 'updated_by') String? updatedBy
});




}
/// @nodoc
class _$PricingConfigCopyWithImpl<$Res>
    implements $PricingConfigCopyWith<$Res> {
  _$PricingConfigCopyWithImpl(this._self, this._then);

  final PricingConfig _self;
  final $Res Function(PricingConfig) _then;

/// Create a copy of PricingConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? serviceType = null,Object? baseRate = null,Object? mistriDailyWage = null,Object? beldarDailyWage = null,Object? materialCoefficient = null,Object? additionalMeta = null,Object? updatedAt = freezed,Object? updatedBy = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,baseRate: null == baseRate ? _self.baseRate : baseRate // ignore: cast_nullable_to_non_nullable
as double,mistriDailyWage: null == mistriDailyWage ? _self.mistriDailyWage : mistriDailyWage // ignore: cast_nullable_to_non_nullable
as double,beldarDailyWage: null == beldarDailyWage ? _self.beldarDailyWage : beldarDailyWage // ignore: cast_nullable_to_non_nullable
as double,materialCoefficient: null == materialCoefficient ? _self.materialCoefficient : materialCoefficient // ignore: cast_nullable_to_non_nullable
as double,additionalMeta: null == additionalMeta ? _self.additionalMeta : additionalMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PricingConfig].
extension PricingConfigPatterns on PricingConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PricingConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PricingConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PricingConfig value)  $default,){
final _that = this;
switch (_that) {
case _PricingConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PricingConfig value)?  $default,){
final _that = this;
switch (_that) {
case _PricingConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'service_type')  String serviceType, @JsonKey(name: 'base_rate')  double baseRate, @JsonKey(name: 'mistri_daily_wage')  double mistriDailyWage, @JsonKey(name: 'beldar_daily_wage')  double beldarDailyWage, @JsonKey(name: 'material_coefficient')  double materialCoefficient, @JsonKey(name: 'additional_meta')  Map<String, dynamic> additionalMeta, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'updated_by')  String? updatedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PricingConfig() when $default != null:
return $default(_that.id,_that.serviceType,_that.baseRate,_that.mistriDailyWage,_that.beldarDailyWage,_that.materialCoefficient,_that.additionalMeta,_that.updatedAt,_that.updatedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'service_type')  String serviceType, @JsonKey(name: 'base_rate')  double baseRate, @JsonKey(name: 'mistri_daily_wage')  double mistriDailyWage, @JsonKey(name: 'beldar_daily_wage')  double beldarDailyWage, @JsonKey(name: 'material_coefficient')  double materialCoefficient, @JsonKey(name: 'additional_meta')  Map<String, dynamic> additionalMeta, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'updated_by')  String? updatedBy)  $default,) {final _that = this;
switch (_that) {
case _PricingConfig():
return $default(_that.id,_that.serviceType,_that.baseRate,_that.mistriDailyWage,_that.beldarDailyWage,_that.materialCoefficient,_that.additionalMeta,_that.updatedAt,_that.updatedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'service_type')  String serviceType, @JsonKey(name: 'base_rate')  double baseRate, @JsonKey(name: 'mistri_daily_wage')  double mistriDailyWage, @JsonKey(name: 'beldar_daily_wage')  double beldarDailyWage, @JsonKey(name: 'material_coefficient')  double materialCoefficient, @JsonKey(name: 'additional_meta')  Map<String, dynamic> additionalMeta, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'updated_by')  String? updatedBy)?  $default,) {final _that = this;
switch (_that) {
case _PricingConfig() when $default != null:
return $default(_that.id,_that.serviceType,_that.baseRate,_that.mistriDailyWage,_that.beldarDailyWage,_that.materialCoefficient,_that.additionalMeta,_that.updatedAt,_that.updatedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PricingConfig implements PricingConfig {
  const _PricingConfig({this.id, @JsonKey(name: 'service_type') required this.serviceType, @JsonKey(name: 'base_rate') required this.baseRate, @JsonKey(name: 'mistri_daily_wage') required this.mistriDailyWage, @JsonKey(name: 'beldar_daily_wage') required this.beldarDailyWage, @JsonKey(name: 'material_coefficient') this.materialCoefficient = 1.0, @JsonKey(name: 'additional_meta') final  Map<String, dynamic> additionalMeta = const <String, dynamic>{}, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'updated_by') this.updatedBy}): _additionalMeta = additionalMeta;
  factory _PricingConfig.fromJson(Map<String, dynamic> json) => _$PricingConfigFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'service_type') final  String serviceType;
@override@JsonKey(name: 'base_rate') final  double baseRate;
@override@JsonKey(name: 'mistri_daily_wage') final  double mistriDailyWage;
@override@JsonKey(name: 'beldar_daily_wage') final  double beldarDailyWage;
@override@JsonKey(name: 'material_coefficient') final  double materialCoefficient;
 final  Map<String, dynamic> _additionalMeta;
@override@JsonKey(name: 'additional_meta') Map<String, dynamic> get additionalMeta {
  if (_additionalMeta is EqualUnmodifiableMapView) return _additionalMeta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_additionalMeta);
}

@override@JsonKey(name: 'updated_at') final  String? updatedAt;
@override@JsonKey(name: 'updated_by') final  String? updatedBy;

/// Create a copy of PricingConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PricingConfigCopyWith<_PricingConfig> get copyWith => __$PricingConfigCopyWithImpl<_PricingConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PricingConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PricingConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.serviceType, serviceType) || other.serviceType == serviceType)&&(identical(other.baseRate, baseRate) || other.baseRate == baseRate)&&(identical(other.mistriDailyWage, mistriDailyWage) || other.mistriDailyWage == mistriDailyWage)&&(identical(other.beldarDailyWage, beldarDailyWage) || other.beldarDailyWage == beldarDailyWage)&&(identical(other.materialCoefficient, materialCoefficient) || other.materialCoefficient == materialCoefficient)&&const DeepCollectionEquality().equals(other._additionalMeta, _additionalMeta)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,serviceType,baseRate,mistriDailyWage,beldarDailyWage,materialCoefficient,const DeepCollectionEquality().hash(_additionalMeta),updatedAt,updatedBy);

@override
String toString() {
  return 'PricingConfig(id: $id, serviceType: $serviceType, baseRate: $baseRate, mistriDailyWage: $mistriDailyWage, beldarDailyWage: $beldarDailyWage, materialCoefficient: $materialCoefficient, additionalMeta: $additionalMeta, updatedAt: $updatedAt, updatedBy: $updatedBy)';
}


}

/// @nodoc
abstract mixin class _$PricingConfigCopyWith<$Res> implements $PricingConfigCopyWith<$Res> {
  factory _$PricingConfigCopyWith(_PricingConfig value, $Res Function(_PricingConfig) _then) = __$PricingConfigCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'service_type') String serviceType,@JsonKey(name: 'base_rate') double baseRate,@JsonKey(name: 'mistri_daily_wage') double mistriDailyWage,@JsonKey(name: 'beldar_daily_wage') double beldarDailyWage,@JsonKey(name: 'material_coefficient') double materialCoefficient,@JsonKey(name: 'additional_meta') Map<String, dynamic> additionalMeta,@JsonKey(name: 'updated_at') String? updatedAt,@JsonKey(name: 'updated_by') String? updatedBy
});




}
/// @nodoc
class __$PricingConfigCopyWithImpl<$Res>
    implements _$PricingConfigCopyWith<$Res> {
  __$PricingConfigCopyWithImpl(this._self, this._then);

  final _PricingConfig _self;
  final $Res Function(_PricingConfig) _then;

/// Create a copy of PricingConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? serviceType = null,Object? baseRate = null,Object? mistriDailyWage = null,Object? beldarDailyWage = null,Object? materialCoefficient = null,Object? additionalMeta = null,Object? updatedAt = freezed,Object? updatedBy = freezed,}) {
  return _then(_PricingConfig(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,serviceType: null == serviceType ? _self.serviceType : serviceType // ignore: cast_nullable_to_non_nullable
as String,baseRate: null == baseRate ? _self.baseRate : baseRate // ignore: cast_nullable_to_non_nullable
as double,mistriDailyWage: null == mistriDailyWage ? _self.mistriDailyWage : mistriDailyWage // ignore: cast_nullable_to_non_nullable
as double,beldarDailyWage: null == beldarDailyWage ? _self.beldarDailyWage : beldarDailyWage // ignore: cast_nullable_to_non_nullable
as double,materialCoefficient: null == materialCoefficient ? _self.materialCoefficient : materialCoefficient // ignore: cast_nullable_to_non_nullable
as double,additionalMeta: null == additionalMeta ? _self._additionalMeta : additionalMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
