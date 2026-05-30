// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Package _$PackageFromJson(Map<String, dynamic> json) => _Package(
  id: json['id'] as String,
  title: json['title'] as String,
  durationMinutes: (json['duration_minutes'] as num).toInt(),
  price: (json['base_price'] as num).toDouble(),
  inclusions:
      (json['inclusions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$PackageToJson(_Package instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'duration_minutes': instance.durationMinutes,
  'base_price': instance.price,
  'inclusions': instance.inclusions,
};
