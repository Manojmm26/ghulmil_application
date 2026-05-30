import 'package:freezed_annotation/freezed_annotation.dart';

part 'provider.freezed.dart';
part 'provider.g.dart';

@freezed
abstract class Provider with _$Provider {
  const factory Provider({
    required String id,
    required String name,
    required String photoUrl,
    required double rating,
    required bool verified,
    required List<String> languages,
  }) = _Provider;

  factory Provider.fromJson(Map<String, dynamic> json) => _$ProviderFromJson(json);
}
