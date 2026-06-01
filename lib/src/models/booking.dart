import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ghulmil_application/src/models/provider.dart';
import 'package:ghulmil_application/src/models/price_breakdown.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    @JsonKey(name: 'service_id') required String serviceId,
    @JsonKey(name: 'package_id') required String packageId,
    @JsonKey(name: 'provider_id') String? providerId,
    required BookingStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'scheduled_at') DateTime? scheduledAt,
    PriceBreakdown? price,
    Provider? provider,
    @JsonKey(name: 'special_instructions') String? notes,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}

enum BookingStatus { pending, confirmed, enroute, inProgress, completed, cancelled }
