import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/models/booking.dart';
import 'package:ghulmil_application/src/providers/api_client_provider.dart';

final bookingDetailsProvider = FutureProvider.family<Booking, String>((ref, bookingId) async {
  if (bookingId.startsWith('mock_booking_')) {
    return Booking(
      id: bookingId,
      serviceId: 'civil_masonry',
      packageId: 'mock_package_id',
      providerId: 'mock_provider_id',
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
      scheduledAt: DateTime.now().add(const Duration(days: 2)),
    );
  }

  final apiClient = ref.watch(apiClientProvider);
  final result = await apiClient.getBooking(bookingId);
  if (result == null) {
    throw Exception('Booking not found');
  }
  return result;
});

final userBookingsProvider = FutureProvider.autoDispose<List<Booking>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.getUserBookings();
});
