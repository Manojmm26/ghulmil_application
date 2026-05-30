import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/models/location_update.dart';
import 'package:ghulmil_application/src/services/tracking_service.dart';

final trackingServiceProvider = Provider<TrackingService>((ref) {
  return TrackingService();
});

final trackingProvider = StreamProvider.family<LocationUpdate, String>((ref, bookingId) {
  final trackingService = ref.watch(trackingServiceProvider);
  return trackingService.trackBooking(bookingId);
});
