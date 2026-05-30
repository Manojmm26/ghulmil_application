import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ghulmil_application/src/models/address.dart';
import 'package:ghulmil_application/src/models/payment_method.dart';

part 'booking_draft.freezed.dart';
part 'booking_draft.g.dart';

@freezed
abstract class BookingDraft with _$BookingDraft {
  const factory BookingDraft({
    String? id,
    required String serviceId,
    String? packageId,
    DateTime? scheduledAt,
    Address? address,
    List<String>? addons,
    PaymentMethod? paymentMethod,
    String? notes,
  }) = _BookingDraft;

  factory BookingDraft.fromJson(Map<String, dynamic> json) => _$BookingDraftFromJson(json);
}
