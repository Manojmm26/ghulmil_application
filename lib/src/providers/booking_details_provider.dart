import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/models/booking.dart';
import 'package:ghulmil_application/src/providers/api_client_provider.dart';

final bookingDetailsProvider = FutureProvider.family<Booking, String>((ref, bookingId) async {
  final apiClient = ref.watch(apiClientProvider);
  final result = await apiClient.getBooking(bookingId);
  if (result == null) {
    throw Exception('Booking not found');
  }
  return result;
});
