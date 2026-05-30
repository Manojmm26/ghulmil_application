import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/providers/api_client_provider.dart';
import 'package:ghulmil_application/src/services/booking_service.dart';

final bookingServiceProvider = Provider<BookingService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingService(apiClient);
});
