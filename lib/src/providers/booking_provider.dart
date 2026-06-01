import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/models/address.dart';
import 'package:ghulmil_application/src/models/booking.dart';
import 'package:ghulmil_application/src/models/booking_draft.dart';
import 'package:ghulmil_application/src/models/payment_method.dart';
import 'package:ghulmil_application/src/providers/booking_service_provider.dart';

class BookingDraftNotifier extends Notifier<BookingDraft?> {
  @override
  BookingDraft? build() {
    return null;
  }

  void startDraft(String serviceId) {
    state = BookingDraft(serviceId: serviceId);
  }

  void clearDraft() {
    state = null;
  }

  void setPackage(String packageId) {
    if (state == null) return;
    state = state!.copyWith(packageId: packageId);
  }

  void setNotes(String notes) {
    if (state == null) return;
    state = state!.copyWith(notes: notes);
  }

  void setSlot(DateTime scheduledAt) {
    if (state == null) return;
    state = state!.copyWith(scheduledAt: scheduledAt);
  }

  void setAddress(Address address) {
    if (state == null) return;
    state = state!.copyWith(address: address);
  }

  void setPaymentMethod(PaymentMethod paymentMethod) {
    if (state == null) return;
    state = state!.copyWith(paymentMethod: paymentMethod);
  }

  Future<Booking?> commitBooking() async {
    if (state == null) return null;
    final bookingService = ref.read(bookingServiceProvider);
    final booking = await bookingService.createBooking(state!);
    clearDraft();
    return booking;
  }
}

final bookingDraftProvider = NotifierProvider<BookingDraftNotifier, BookingDraft?>(
  () => BookingDraftNotifier(),
);
