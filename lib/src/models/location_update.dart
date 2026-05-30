import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_update.freezed.dart';
part 'location_update.g.dart';

@freezed
abstract class LocationUpdate with _$LocationUpdate {
  const factory LocationUpdate({
    required double lat,
    required double lng,
    required int etaMinutes,
  }) = _LocationUpdate;

  factory LocationUpdate.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateFromJson(json);
}
