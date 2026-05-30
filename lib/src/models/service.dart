import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ghulmil_application/src/models/package.dart';

part 'service.freezed.dart';
part 'service.g.dart';

@freezed
abstract class Service with _$Service {
  const factory Service({
    required String id,
    required String title,
    String? subtitle,
    @Default(<Package>[]) List<Package> packages,
    @Default(0.0) double rating,
    @Default(<String>[]) List<String> tags,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
}
