// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Slot _$SlotFromJson(Map<String, dynamic> json) => _Slot(
  start: DateTime.parse(json['start'] as String),
  end: DateTime.parse(json['end'] as String),
  providerCount: (json['providerCount'] as num).toInt(),
);

Map<String, dynamic> _$SlotToJson(_Slot instance) => <String, dynamic>{
  'start': instance.start.toIso8601String(),
  'end': instance.end.toIso8601String(),
  'providerCount': instance.providerCount,
};
