// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  serviceId: json['serviceId'] as String,
  packageId: json['packageId'] as String,
  providerId: json['providerId'] as String,
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  price: json['price'] == null
      ? null
      : PriceBreakdown.fromJson(json['price'] as Map<String, dynamic>),
  provider: json['provider'] == null
      ? null
      : Provider.fromJson(json['provider'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'serviceId': instance.serviceId,
  'packageId': instance.packageId,
  'providerId': instance.providerId,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'scheduledAt': instance.scheduledAt?.toIso8601String(),
  'price': instance.price?.toJson(),
  'provider': instance.provider?.toJson(),
};

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.enroute: 'enroute',
  BookingStatus.inProgress: 'inProgress',
  BookingStatus.completed: 'completed',
  BookingStatus.cancelled: 'cancelled',
};
