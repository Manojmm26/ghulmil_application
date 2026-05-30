import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ghulmil_application/src/models/provider.dart';
import 'package:ghulmil_application/src/models/price_breakdown.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String serviceId,
    required String packageId,
    required String providerId,
    required BookingStatus status,
    required DateTime createdAt,
    DateTime? scheduledAt,
    PriceBreakdown? price,
    Provider? provider,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}

enum BookingStatus { pending, confirmed, enroute, inProgress, completed, cancelled }
