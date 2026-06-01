import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghulmil_application/src/models/booking.dart';

void main() {
  group('Booking Model Deserialization', () {
    test('should correctly deserialize from Supabase snake_case JSON (with null provider_id)', () {
      final supabaseBookingJson = {
        'id': 'd6738eb0-9e3e-4b31-a481-422a04b8d7d4',
        'service_id': 'civil_masonry',
        'package_id': 'mock_package_id',
        'provider_id': null, // Initial booking state before provider assignment
        'status': 'pending',
        'created_at': '2026-05-31T20:14:58.000Z',
        'scheduled_at': '2026-06-02T20:14:58.000Z',
      };

      final booking = Booking.fromJson(supabaseBookingJson);

      expect(booking.id, 'd6738eb0-9e3e-4b31-a481-422a04b8d7d4');
      expect(booking.serviceId, 'civil_masonry');
      expect(booking.packageId, 'mock_package_id');
      expect(booking.providerId, isNull);
      expect(booking.status, BookingStatus.pending);
      expect(booking.createdAt, DateTime.parse('2026-05-31T20:14:58.000Z'));
      expect(booking.scheduledAt, DateTime.parse('2026-06-02T20:14:58.000Z'));
    });
  });
}
