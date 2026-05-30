// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationUpdate _$LocationUpdateFromJson(Map<String, dynamic> json) =>
    _LocationUpdate(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      etaMinutes: (json['etaMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$LocationUpdateToJson(_LocationUpdate instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'etaMinutes': instance.etaMinutes,
    };
