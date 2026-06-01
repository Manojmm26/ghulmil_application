// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  serviceId: json['service_id'] as String,
  packageId: json['package_id'] as String,
  providerId: json['provider_id'] as String?,
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['created_at'] as String),
  scheduledAt: json['scheduled_at'] == null
      ? null
      : DateTime.parse(json['scheduled_at'] as String),
  price: json['price'] == null
      ? null
      : PriceBreakdown.fromJson(json['price'] as Map<String, dynamic>),
  provider: json['provider'] == null
      ? null
      : Provider.fromJson(json['provider'] as Map<String, dynamic>),
  notes: json['special_instructions'] as String?,
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'service_id': instance.serviceId,
  'package_id': instance.packageId,
  'provider_id': instance.providerId,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'created_at': instance.createdAt.toIso8601String(),
  'scheduled_at': instance.scheduledAt?.toIso8601String(),
  'price': instance.price?.toJson(),
  'provider': instance.provider?.toJson(),
  'special_instructions': instance.notes,
};

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.enroute: 'enroute',
  BookingStatus.inProgress: 'inProgress',
  BookingStatus.completed: 'completed',
  BookingStatus.cancelled: 'cancelled',
};
