import 'dart:developer';
import 'dart:typed_data';
import 'package:ghulmil_application/src/models/service.dart';
import 'package:ghulmil_application/src/models/booking.dart';
import 'package:ghulmil_application/src/models/booking_draft.dart';
import 'package:ghulmil_application/src/models/slot.dart';
import 'package:ghulmil_application/src/models/address.dart';
import 'package:ghulmil_application/src/core/supabase_config.dart';

class SupabaseService {
  final _supabase = SupabaseConfig.client;

  // =====================================
  // UTILITY METHODS
  // =====================================

  Future<T> _executeWithRetry<T>({
    required Future<T> Function() operation,
    required String operationName,
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempt++;
        log('$operationName attempt $attempt failed: $error', name: 'SupabaseService');

        // Check if it's a retryable error
        if (attempt >= maxRetries ||
            error.toString().contains('infinite recursion') ||
            error.toString().contains('42P17')) {
          log('$operationName failed permanently: $error', name: 'SupabaseService');
          rethrow;
        }

        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(milliseconds: 1000 * attempt));
      }
    }
    throw Exception('$operationName failed after $maxRetries attempts');
  }

  Future<String?> _getUserLocation() async {
    // TODO: Implement actual location service using geolocator or similar package
    // For now, return a default location or null to use database defaults
    // This should be replaced with actual GPS coordinates when location permissions are granted
    return null; // Let the database use its default location logic
  }

  // =====================================
  // SERVICES
  // =====================================

  Future<List<Service>> getServices({
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      log('Fetching services (category: ${category ?? 'all'}, limit: $limit, offset: $offset)', name: 'SupabaseService');
      var query = _supabase
          .from('services')
          .select('*, packages:service_packages(*), category:service_categories(*)')
          .eq('is_active', true);

      if (category != null) {
        query = query.eq('category.name', category);
      }

      final response = await query
          .range(offset, offset + limit - 1)
          .order('is_featured', ascending: false)
          .order('rating', ascending: false);

      final services = response.map((json) => Service.fromJson(json)).toList();
      log('Fetched ${services.length} services from Supabase', name: 'SupabaseService');
      return services;
    } catch (error) {
      log('Error fetching services: $error', name: 'SupabaseService');
      // Return empty list instead of throwing to prevent app crash
      return [];
    }
  }

  Future<Service?> getService(String serviceId) async {
    try {
      log('Fetching service detail for $serviceId', name: 'SupabaseService');
      final response = await _supabase
          .from('services')
          .select('*, packages:service_packages(*), category:service_categories(*)')
          .eq('id', serviceId)
          .single();

      final service = Service.fromJson(response);
      log('Fetched service ${service.title} with ${service.packages.length} packages', name: 'SupabaseService');
      return service;
    } catch (error) {
      log('Error fetching service: $error', name: 'SupabaseService');
      return null;
    }
  }

  Future<List<Slot>> getAvailability(String serviceId, DateTime date) async {
    try {
      final response = await _supabase
          .rpc('get_service_availability', params: {
            'service_id_param': serviceId,
            'date_param': date.toIso8601String().split('T')[0],
          });

      return response.map((slot) => Slot(
        start: DateTime.parse(slot['start_time']),
        end: DateTime.parse(slot['end_time']),
        providerCount: slot['provider_count'],
      )).toList();
    } catch (error) {
      log('Error fetching availability: $error', name: 'SupabaseService');
      return [];
    }
  }

  // =====================================
  // BOOKINGS
  // =====================================

  Future<List<Booking>> getUserBookings({int limit = 20, int offset = 0}) async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('bookings')
          .select('*, service:services(*), provider:providers(*)')
          .eq('customer_id', userId)
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);

      return response.map((json) => Booking.fromJson(json)).toList();
    } catch (error) {
      log('Error fetching bookings: $error', name: 'SupabaseService');
      return [];
    }
  }

  Future<Booking?> getBooking(String bookingId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*, service:services(*), provider:providers(*)')
          .eq('id', bookingId)
          .single();

      return Booking.fromJson(response);
    } catch (error) {
      log('Error fetching booking: $error', name: 'SupabaseService');
      return null;
    }
  }

  Future<Booking?> createBooking(BookingDraft draft) async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null || draft.address == null) return null;

      final response = await _supabase
          .from('bookings')
          .insert({
            'customer_id': userId,
            'service_id': draft.serviceId,
            'package_id': draft.packageId,
            'address_id': draft.address!.id, // Use address ID from the Address object
            'scheduled_at': draft.scheduledAt?.toIso8601String(),
            'special_instructions': draft.notes,
            'total_amount': 0.0, // Will be calculated by database triggers
          })
          .select()
          .single();

      return Booking.fromJson(response);
    } catch (error) {
      log('Error creating booking: $error', name: 'SupabaseService');
      return null;
    }
  }

  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      final response = await _supabase
          .from('bookings')
          .update({
            'status': 'cancelled',
            'cancellation_reason': reason,
            'cancelled_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      return response.error == null;
    } catch (error) {
      log('Error cancelling booking: $error', name: 'SupabaseService');
      return false;
    }
  }

  // =====================================
  // ADDRESSES
  // =====================================

  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return null;

    return await _executeWithRetry<Map<String, dynamic>?>(
      operation: () async {
        final adminResponse = await _supabase.auth.admin.getUserById(userId);

        if (adminResponse.user != null) {
          final profileData = await _supabase
              .from('users')
              .select('*')
              .eq('id', userId)
              .single();

          return {
            ...adminResponse.user!.toJson(),
            'profile': profileData,
          };
        }

        return null;
      },
      operationName: 'getUserProfile',
    );
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
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return null;

    return await _executeWithRetry<Address?>(
      operation: () async {
        final addressData = {
          'user_id': userId,
          'line1': street,
          'city': city,
          'state': state,
          'postal_code': zipCode,
          'country': 'India',
          'access_notes': label,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        };

        final record = await _supabase
            .from('addresses')
            .insert(addressData)
            .select()
            .single();

        return Address.fromJson(record);
      },
      operationName: 'createAddress',
    );
  }

  Future<List<Address>> getUserAddresses() async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return [];

    return await _executeWithRetry<List<Address>>(
      operation: () async {
        final records = await _supabase
            .from('addresses')
            .select('*')
            .eq('user_id', userId)
            .order('is_default', ascending: false);

        return records.map((json) => Address.fromJson(json)).toList();
      },
      operationName: 'getUserAddresses',
    );
  }

  Future<bool> updateUserProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return false;

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    updates['updated_at'] = DateTime.now().toIso8601String();

    return await _executeWithRetry<bool>(
      operation: () async {
        final response = await _supabase
            .from('users')
            .update(updates)
            .eq('id', userId);
        return response.error == null;
      },
      operationName: 'updateUserProfile',
    );
  }

  // =====================================
  // REAL-TIME SUBSCRIPTIONS
  // =====================================

  Stream<Booking> getBookingUpdates(String bookingId) {
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('id', bookingId)
        .map((data) => Booking.fromJson(data.first));
  }

  Stream<List<Booking>> getUserBookingsStream() {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('customer_id', userId)
        .order('created_at')
        .map((data) => data.map((json) => Booking.fromJson(json)).toList());
  }

  // =====================================
  // PROVIDERS
  // =====================================

  Future<List<Map<String, dynamic>>> getAvailableProviders({
    required String serviceId,
    required DateTime dateTime,
    int limit = 10,
  }) async {
    try {
      final response = await _supabase.rpc('find_nearby_providers', params: {
        'service_id_param': serviceId,
        'customer_location': await _getUserLocation() ?? 'POINT(0 0)', // TODO: Get actual user location
        'max_distance_km': 50,
        'limit_count': limit,
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      log('Error fetching providers: $error', name: 'SupabaseService');
      return [];
    }
  }

  // =====================================
  // FILE UPLOAD
  // =====================================

  Future<String?> uploadFile({
    required String bucket,
    required String filePath,
    required List<int> fileBytes,
    String? fileName,
  }) async {
    try {
      final fileExt = filePath.split('.').last;
      final finalFileName = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      final response = await _supabase.storage
          .from(bucket)
          .uploadBinary(finalFileName, Uint8List.fromList(fileBytes));

      if (response.isEmpty) {
        log('Upload failed: Empty response', name: 'SupabaseService');
        return null;
      }

      final publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(finalFileName);

      return publicUrl;
    } catch (error) {
      log('Error uploading file: $error', name: 'SupabaseService');
      return null;
    }
  }

  Future<String?> uploadAvatar(List<int> imageBytes) async {
    return uploadFile(
      bucket: 'avatars',
      filePath: 'avatar.jpg',
      fileBytes: imageBytes,
      fileName: 'avatar_${SupabaseConfig.currentUser?.id}.jpg',
    );
  }


  Future<String?> uploadServiceImage(List<int> imageBytes, String serviceId) async {
    return uploadFile(
      bucket: 'service-images',
      filePath: 'service.jpg',
      fileBytes: imageBytes,
      fileName: 'service_${serviceId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }
}
