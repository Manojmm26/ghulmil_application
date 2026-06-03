import 'package:freezed_annotation/freezed_annotation.dart';

part 'pricing_config.freezed.dart';
part 'pricing_config.g.dart';

@freezed
abstract class PricingConfig with _$PricingConfig {
  const factory PricingConfig({
    String? id,
    @JsonKey(name: 'service_type') required String serviceType,
    @JsonKey(name: 'base_rate') required double baseRate,
    @JsonKey(name: 'mistri_daily_wage') required double mistriDailyWage,
    @JsonKey(name: 'beldar_daily_wage') required double beldarDailyWage,
    @JsonKey(name: 'material_coefficient') @Default(1.0) double materialCoefficient,
    @JsonKey(name: 'additional_meta') @Default(<String, dynamic>{}) Map<String, dynamic> additionalMeta,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'updated_by') String? updatedBy,
  }) = _PricingConfig;

  factory PricingConfig.fromJson(Map<String, dynamic> json) => _$PricingConfigFromJson(json);
}
