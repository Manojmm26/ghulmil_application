import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_breakdown.freezed.dart';
part 'price_breakdown.g.dart';

@freezed
abstract class PriceBreakdown with _$PriceBreakdown {
  const factory PriceBreakdown({
    required double subtotal,
    required double tax,
    required double total,
    List<LineItem>? lineItems,
  }) = _PriceBreakdown;

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) => _$PriceBreakdownFromJson(json);
}

@freezed
abstract class LineItem with _$LineItem {
  const factory LineItem({
    required String label,
    required double amount,
  }) = _LineItem;

  factory LineItem.fromJson(Map<String, dynamic> json) => _$LineItemFromJson(json);
}
