// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_breakdown.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceBreakdown _$PriceBreakdownFromJson(Map<String, dynamic> json) =>
    _PriceBreakdown(
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      lineItems: (json['lineItems'] as List<dynamic>?)
          ?.map((e) => LineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PriceBreakdownToJson(_PriceBreakdown instance) =>
    <String, dynamic>{
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'total': instance.total,
      'lineItems': instance.lineItems?.map((e) => e.toJson()).toList(),
    };

_LineItem _$LineItemFromJson(Map<String, dynamic> json) => _LineItem(
  label: json['label'] as String,
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$LineItemToJson(_LineItem instance) => <String, dynamic>{
  'label': instance.label,
  'amount': instance.amount,
};
