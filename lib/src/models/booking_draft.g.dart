// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingDraft _$BookingDraftFromJson(
  Map<String, dynamic> json,
) => _BookingDraft(
  id: json['id'] as String?,
  serviceId: json['serviceId'] as String,
  packageId: json['packageId'] as String?,
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  address: json['address'] == null
      ? null
      : Address.fromJson(json['address'] as Map<String, dynamic>),
  addons: (json['addons'] as List<dynamic>?)?.map((e) => e as String).toList(),
  paymentMethod: json['paymentMethod'] == null
      ? null
      : PaymentMethod.fromJson(json['paymentMethod'] as Map<String, dynamic>),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$BookingDraftToJson(_BookingDraft instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceId': instance.serviceId,
      'packageId': instance.packageId,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'address': instance.address?.toJson(),
      'addons': instance.addons,
      'paymentMethod': instance.paymentMethod?.toJson(),
      'notes': instance.notes,
    };
