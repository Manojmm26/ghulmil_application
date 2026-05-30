import 'dart:async';
import 'dart:math';

import 'package:ghulmil_application/src/models/location_update.dart';

class TrackingService {
  // Simulates a WebSocket stream of location updates.
  Stream<LocationUpdate> trackBooking(String bookingId) {
    return Stream.periodic(const Duration(seconds: 3), (i) {
      // Generate a random location update for mocking.
      final random = Random();
      return LocationUpdate(
        lat: 28.6 + (random.nextDouble() * 0.01),
        lng: 77.2 + (random.nextDouble() * 0.01),
        etaMinutes: max(0, 15 - i),
      );
    }).take(15);
  }
}
