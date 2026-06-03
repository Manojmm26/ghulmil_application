// lib/src/services/api_client.dart
import 'package:ghulmil_application/src/models/service.dart';
import 'package:ghulmil_application/src/models/booking.dart';
import 'package:ghulmil_application/src/models/booking_draft.dart';
import 'package:ghulmil_application/src/models/slot.dart';
import 'package:ghulmil_application/src/models/address.dart';
import 'package:ghulmil_application/src/models/pricing_config.dart';
import 'package:ghulmil_application/src/services/supabase_service.dart';

class ApiClient {
  final SupabaseService _supabaseService = SupabaseService();

  // =====================================
  // SERVICES
  // =====================================

  Future<List<Service>> getServices() async {
    return await _supabaseService.getServices();
  }

  Future<Service?> getService(String serviceId) async {
    return await _supabaseService.getService(serviceId);
  }

  Future<List<Slot>> getAvailability(String serviceId, DateTime date) async {
    return await _supabaseService.getAvailability(serviceId, date);
  }

  Future<Booking?> createBooking(BookingDraft draft) async {
    return await _supabaseService.createBooking(draft);
  }

  Future<Booking?> getBooking(String bookingId) async {
    return await _supabaseService.getBooking(bookingId);
  }

  Future<List<Booking>> getUserBookings() async {
    return await _supabaseService.getUserBookings();
  }

  Future<List<Address>> getUserAddresses() async {
    return await _supabaseService.getUserAddresses();
  }

  Future<Address?> createAddress({
    required String label,
    required String street,
    required String city,
    required String state,
    required String zipCode,
    double? latitude,
    double? longitude,
  }) async {
    return await _supabaseService.createAddress(
      label: label,
      street: street,
      city: city,
      state: state,
      zipCode: zipCode,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // =====================================
  // USER PROFILE
  // =====================================

  Future<Map<String, dynamic>?> getUserProfile() async {
    return await _supabaseService.getUserProfile();
  }

  Future<bool> updateUserProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    return await _supabaseService.updateUserProfile(
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
    );
  }

  // =====================================
  // PROVIDERS
  // =====================================

  Future<List<Map<String, dynamic>>> getAvailableProviders({
    required String serviceId,
    required DateTime dateTime,
    int limit = 10,
  }) async {
    return await _supabaseService.getAvailableProviders(
      serviceId: serviceId,
      dateTime: dateTime,
      limit: limit,
    );
  }

  // =====================================
  // FILE UPLOAD
  // =====================================

  Future<String?> uploadAvatar(List<int> imageBytes) async {
    return await _supabaseService.uploadAvatar(imageBytes);
  }

  Future<String?> uploadServiceImage(List<int> imageBytes, String serviceId) async {
    return await _supabaseService.uploadServiceImage(imageBytes, serviceId);
  }

  // =====================================
  // PRICING CONFIGS
  // =====================================

  Future<List<PricingConfig>> getPricingConfigs() async {
    return await _supabaseService.getPricingConfigs();
  }

  Future<bool> updatePricingConfig(String serviceType, Map<String, dynamic> updates) async {
    return await _supabaseService.updatePricingConfig(serviceType, updates);
  }
}
