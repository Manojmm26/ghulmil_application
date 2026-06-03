// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PricingConfig _$PricingConfigFromJson(Map<String, dynamic> json) =>
    _PricingConfig(
      id: json['id'] as String?,
      serviceType: json['service_type'] as String,
      baseRate: (json['base_rate'] as num).toDouble(),
      mistriDailyWage: (json['mistri_daily_wage'] as num).toDouble(),
      beldarDailyWage: (json['beldar_daily_wage'] as num).toDouble(),
      materialCoefficient:
          (json['material_coefficient'] as num?)?.toDouble() ?? 1.0,
      additionalMeta:
          json['additional_meta'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      updatedAt: json['updated_at'] as String?,
      updatedBy: json['updated_by'] as String?,
    );

Map<String, dynamic> _$PricingConfigToJson(_PricingConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'service_type': instance.serviceType,
      'base_rate': instance.baseRate,
      'mistri_daily_wage': instance.mistriDailyWage,
      'beldar_daily_wage': instance.beldarDailyWage,
      'material_coefficient': instance.materialCoefficient,
      'additional_meta': instance.additionalMeta,
      'updated_at': instance.updatedAt,
      'updated_by': instance.updatedBy,
    };
