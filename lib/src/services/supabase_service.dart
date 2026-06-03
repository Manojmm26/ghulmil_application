import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:ghulmil_application/src/models/service.dart';
import 'package:ghulmil_application/src/models/booking.dart';
import 'package:ghulmil_application/src/models/booking_draft.dart';
import 'package:ghulmil_application/src/models/slot.dart';
import 'package:ghulmil_application/src/models/address.dart';
import 'package:ghulmil_application/src/models/price_breakdown.dart';
import 'package:ghulmil_application/src/core/supabase_config.dart';
import 'package:ghulmil_application/src/models/package.dart';
import 'package:ghulmil_application/src/models/pricing_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _supabase = SupabaseConfig.client;
  static final List<Booking> _mockBookings = [];
  
  static final List<PricingConfig> _fallbackPricingConfigs = [
    const PricingConfig(
      serviceType: 'electrical',
      baseRate: 800.0,
      mistriDailyWage: 750.0,
      beldarDailyWage: 450.0,
      materialCoefficient: 1.0,
      additionalMeta: {
        'rough_in_material_rate': 120.0,
        'finish_material_rate': 70.0,
        'rough_in_labor_rate': 50.0,
        'finish_labor_rate': 30.0,
      },
    ),
    const PricingConfig(
      serviceType: 'plumbing',
      baseRate: 900.0,
      mistriDailyWage: 800.0,
      beldarDailyWage: 450.0,
      materialCoefficient: 1.0,
      additionalMeta: {
        'concealed_material_rate': 1500.0,
        'exposed_material_rate': 800.0,
        'concealed_labor_rate': 600.0,
        'exposed_labor_rate': 350.0,
      },
    ),
    const PricingConfig(
      serviceType: 'carpentry',
      baseRate: 1500.0,
      mistriDailyWage: 850.0,
      beldarDailyWage: 450.0,
      materialCoefficient: 1.0,
      additionalMeta: {
        'wardrobe_material_rate': 180.0,
        'other_material_rate': 250.0,
        'wardrobe_labor_rate': 60.0,
        'other_labor_rate': 80.0,
      },
    ),
    const PricingConfig(
      serviceType: 'painting',
      baseRate: 1000.0,
      mistriDailyWage: 800.0,
      beldarDailyWage: 450.0,
      materialCoefficient: 1.0,
      additionalMeta: {
        'fresh_premium_rate': 12.0,
        'fresh_standard_rate': 6.0,
        'repaint_premium_rate': 8.0,
        'repaint_standard_rate': 4.0,
        'labor_only_rate': 3.0,
      },
    ),
    const PricingConfig(
      serviceType: 'flooring',
      baseRate: 1200.0,
      mistriDailyWage: 900.0,
      beldarDailyWage: 450.0,
      materialCoefficient: 1.0,
      additionalMeta: {
        'marble_material_rate': 4.5,
        'tiles_material_rate': 2.0,
        'labor_only_rate': 1.2,
        'mirror_polish_material_premium': 2.5,
        'mirror_polish_labor_premium': 1.5,
      },
    ),
    const PricingConfig(
      serviceType: 'civil',
      baseRate: 1200.0,
      mistriDailyWage: 800.0,
      beldarDailyWage: 450.0,
      materialCoefficient: 1.0,
      additionalMeta: {
        'material_rate_premium': 2.5,
        'material_rate_semi_premium': 1.5,
        'material_rate_standard': 1.0,
        'labor_factor': 0.45,
      },
    ),
  ];

  static final List<PricingConfig> _localPricingConfigs = List.from(_fallbackPricingConfigs);

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

  static final List<Service> _fallbackServices = [
    const Service(
      id: 'bbbb0000-0000-0000-0000-000000000001',
      title: 'Premium Home Deep Clean',
      subtitle: 'Reset your home with a sparkling clean',
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80',
      tags: ['Deep Clean', 'Eco Friendly', 'Top Rated'],
      packages: [
        Package(
          id: 'aaaa0000-0000-0000-0000-000000000001',
          title: 'Essentials Deep Clean',
          price: 89.99,
          inclusions: ['Kitchen degreasing', 'Bathroom sanitizing', 'Dusting & vacuuming'],
          durationMinutes: 180,
        ),
        Package(
          id: 'aaaa0000-0000-0000-0000-000000000002',
          title: 'Luxury Shine Upgrade',
          price: 149.00,
          inclusions: ['Floor polishing', 'Appliance detailing', 'Balcony wash'],
          durationMinutes: 240,
        ),
      ],
    ),
    const Service(
      id: 'bbbb0000-0000-0000-0000-000000000002',
      title: 'Move-In / Move-Out Cleaning',
      subtitle: 'Perfect for fresh beginnings or handover condition',
      rating: 4.6,
      imageUrl: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=800&q=80',
      tags: ['Move In', 'Handover', 'Detailed'],
      packages: [
        Package(
          id: 'aaaa0000-0000-0000-0000-000000000003',
          title: 'Move Prep Standard',
          price: 129.00,
          inclusions: ['Cabinet wipe-down', 'Surface disinfecting', 'Floor scrubbing'],
          durationMinutes: 210,
        ),
      ],
    ),
    const Service(
      id: 'bbbb0000-0000-0000-0000-000000000003',
      title: 'Emergency Plumbing Support',
      subtitle: '24/7 rapid response for leaks and bursts',
      rating: 4.5,
      imageUrl: 'https://images.unsplash.com/photo-1504148455328-c376907d081c?auto=format&fit=crop&w=800&q=80',
      tags: ['Emergency', '24/7', 'Rapid Response'],
      packages: [
        Package(
          id: 'aaaa0000-0000-0000-0000-000000000004',
          title: 'Leak Fix Express',
          price: 79.00,
          inclusions: ['Leak inspection', 'Sealant application', 'Pressure testing'],
          durationMinutes: 90,
        ),
        Package(
          id: 'aaaa0000-0000-0000-0000-000000000005',
          title: 'Fixture Replacement Pro',
          price: 59.00,
          inclusions: ['Fixture installation', 'Seal replacement', 'Leak test'],
          durationMinutes: 75,
        ),
      ],
    ),
    const Service(
      id: 'bbbb0000-0000-0000-0000-000000000004',
      title: 'Smart Home Electrical Setup',
      subtitle: 'Install and configure smart lighting & devices',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1558002038-1055907df827?auto=format&fit=crop&w=800&q=80',
      tags: ['Smart Home', 'Installation', 'Certified'],
      packages: [
        Package(
          id: 'aaaa0000-0000-0000-0000-000000000006',
          title: 'Smart Lighting Starter',
          price: 129.00,
          inclusions: ['Switch installation', 'Device pairing', 'Basic usage training'],
          durationMinutes: 150,
        ),
        Package(
          id: 'aaaa0000-0000-0000-0000-000000000007',
          title: 'Automation Master Package',
          price: 199.00,
          inclusions: ['Scene configuration', 'Energy audit', 'Mobile app walkthrough'],
          durationMinutes: 210,
        ),
      ],
    ),
    const Service(
      id: 'bbbb0000-0000-0000-0000-000000000005',
      title: 'Civil Masonry & Concrete (Lenter-Chunai)',
      subtitle: 'Raj Mistri & Beldar structural masonry services',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?auto=format&fit=crop&w=800&q=80',
      tags: ['Raj Mistri', 'Slab/Lenter', 'Materials Flag'],
      packages: [
        Package(
          id: 'aaaa0000-0000-0000-0000-000000000008',
          title: 'Structure & Brickwork Consultation',
          price: 1200.00,
          inclusions: ['Foundation inspection', 'Sand-mix quality test', 'Workforce sizing proposal'],
          durationMinutes: 120,
        ),
      ],
    ),
    const Service(
      id: 'bbbb0000-0000-0000-0000-000000000006',
      title: 'Custom Carpentry Woodwork (Badhai Kaam)',
      subtitle: 'Modular kitchens, custom almirahs, and wardrobe laminate fitments',
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?auto=format&fit=crop&w=800&q=80',
      tags: ['Badhai', 'Modular Cabinet', 'Sunmica laminate'],
      packages: [
        Package(
          id: 'aaaa0000-0000-0000-0000-000000000009',
          title: 'Modular Woodwork Catalog Consulting',
          price: 1500.00,
          inclusions: ['Dimensions verification', 'Sunmica catalog analysis', 'Cabinet design proposal'],
          durationMinutes: 90,
        ),
      ],
    ),
    const Service(
      id: 'bbbb0000-0000-0000-0000-000000000007',
      title: 'Wall Painting & Premium Textures (Rangai-Putty)',
      subtitle: 'OBD, premium emulsion and Royal Play marble textures',
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1562259949-e8e7689d7828?auto=format&fit=crop&w=800&q=80',
      tags: ['Putty/Sanding', 'Royal Play', 'Fresh Paint'],
      packages: [
        Package(
          id: 'aaaa0000-0000-0000-0000-000000000010',
          title: 'Wall Seepage Audit & Texture Catalog',
          price: 1000.00,
          inclusions: ['Moisture levels measurement', 'Putty adhesion check', 'Metallic stencils review'],
          durationMinutes: 90,
        ),
      ],
    ),
    const Service(
      id: 'bbbb0000-0000-0000-0000-000000000008',
      title: 'Tile Layout & Marble Diamond Ghisai',
      subtitle: 'Premium floor tiling and mirror-finish stone polishing',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=800&q=80',
      tags: ['Tile Layout', 'Diamond Ghisai', 'Marble Mirror'],
      packages: [
        Package(
          id: 'aaaa0000-0000-0000-0000-000000000011',
          title: 'Floor Level Assessment & Polish Test',
          price: 1200.00,
          inclusions: ['Spirit-level flatness test', 'Spot polishing trial', 'Joint lines alignment check'],
          durationMinutes: 120,
        ),
      ],
    ),
  ];

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
      
      if (services.isEmpty) {
        log('No active services in database, returning rich fallback catalog', name: 'SupabaseService');
        return _fallbackServices;
      }
      
      return services;
    } catch (error) {
      log('Error fetching services: $error. Returning rich fallback catalog.', name: 'SupabaseService');
      return _fallbackServices;
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
      log('Error fetching service: $error. Attempting local lookup.', name: 'SupabaseService');
      try {
        final localService = _fallbackServices.firstWhere((s) => s.id == serviceId);
        log('Local lookup successful for ${localService.title}', name: 'SupabaseService');
        return localService;
      } catch (_) {}
      return null;
    }
  }

  Future<List<Slot>> getAvailability(String serviceId, DateTime date) async {
    print('DEBUG: getAvailability called for serviceId=$serviceId, date=$date');
    try {
      final response = await _supabase
          .rpc('get_service_availability', params: {
            'service_id_param': serviceId,
            'date_param': date.toIso8601String().split('T')[0],
          });
      print('DEBUG: Supabase RPC response=$response');

      if (response != null) {
        final List<Slot> slots = (response as List).map((slot) => Slot(
          start: DateTime.parse(slot['start_time']),
          end: DateTime.parse(slot['end_time']),
          providerCount: slot['provider_count'],
        )).toList();
        print('DEBUG: Parsed slots count=${slots.length}');
        if (slots.isNotEmpty) return slots;
      }
    } catch (error) {
      print('DEBUG: Error in getAvailability=$error');
    }

    print('DEBUG: Returning mock fallback slots');
    // Fallback: Generate mock slots for the given date (9 AM, 11 AM, 1 PM, 3 PM, 5 PM)
    final year = date.year;
    final month = date.month;
    final day = date.day;
    return [
      Slot(start: DateTime(year, month, day, 9, 0), end: DateTime(year, month, day, 10, 0), providerCount: 3),
      Slot(start: DateTime(year, month, day, 11, 0), end: DateTime(year, month, day, 12, 0), providerCount: 3),
      Slot(start: DateTime(year, month, day, 13, 0), end: DateTime(year, month, day, 14, 0), providerCount: 2),
      Slot(start: DateTime(year, month, day, 15, 0), end: DateTime(year, month, day, 16, 0), providerCount: 4),
      Slot(start: DateTime(year, month, day, 17, 0), end: DateTime(year, month, day, 18, 0), providerCount: 3),
    ];
  }

  // =====================================
  // BOOKINGS
  // =====================================

  Future<List<Booking>> getUserBookings({int limit = 20, int offset = 0}) async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) {
        return _mockBookings;
      }

      final response = await _supabase
          .from('bookings')
          .select('*, service:services(*), provider:providers(*)')
          .eq('customer_id', userId)
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);

      final realBookings = response.map((json) => Booking.fromJson(json)).toList();
      return [..._mockBookings, ...realBookings];
    } catch (error) {
      log('Error fetching bookings: $error', name: 'SupabaseService');
      return _mockBookings;
    }
  }

  Future<Booking?> getBooking(String bookingId) async {
    if (bookingId.startsWith('mock_booking_')) {
      log('SupabaseService getBooking: mock booking detected. Looking up in-memory.', name: 'SupabaseService');
      return _mockBookings.firstWhere(
        (b) => b.id == bookingId,
        orElse: () => Booking(
          id: bookingId,
          serviceId: 'civil_masonry',
          packageId: 'mock_package_id',
          providerId: 'mock_provider_id',
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now().add(const Duration(days: 2)),
        ),
      );
    }

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

      // Extract details from notes if any
      Map<String, dynamic>? customReqs;
      if (draft.notes != null) {
        try {
          customReqs = jsonDecode(draft.notes!);
        } catch (_) {}
      }
      final bool isCustomService = customReqs != null && (
        customReqs['service_type'] == 'civil' ||
        customReqs['service_type'] == 'civil_masonry' ||
        customReqs['service_type'] == 'electrical' ||
        customReqs['service_type'] == 'plumbing' ||
        customReqs['service_type'] == 'carpentry' ||
        customReqs['service_type'] == 'painting' ||
        customReqs['service_type'] == 'flooring'
      );
      final double basePrice = isCustomService
          ? (customReqs!['computed_price'] as num).toDouble()
          : 49.99;
      final double taxPrice = isCustomService
          ? basePrice * 0.05
          : 5.00;
      final double totalPrice = basePrice + taxPrice;

      if (userId == null || draft.address == null) {
        log('Supabase createBooking: Unauthenticated or missing address. Falling back to mock Booking.', name: 'SupabaseService');
        final mockBooking = Booking(
          id: 'mock_booking_${DateTime.now().millisecondsSinceEpoch}',
          serviceId: draft.serviceId,
          packageId: draft.packageId ?? 'mock_package_id',
          providerId: 'mock_provider_id',
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
          scheduledAt: draft.scheduledAt ?? DateTime.now(),
          notes: draft.notes,
          price: PriceBreakdown(
            subtotal: basePrice,
            tax: taxPrice,
            total: totalPrice,
          ),
        );
        _mockBookings.add(mockBooking);
        return mockBooking;
      }

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
      log('Error creating booking: $error. Falling back to mock Booking.', name: 'SupabaseService');
      
      // Extract details from notes if any for the catch fallback as well
      Map<String, dynamic>? customReqs;
      if (draft.notes != null) {
        try {
          customReqs = jsonDecode(draft.notes!);
        } catch (_) {}
      }
      final bool isCustomService = customReqs != null && (
        customReqs['service_type'] == 'civil' ||
        customReqs['service_type'] == 'civil_masonry' ||
        customReqs['service_type'] == 'electrical' ||
        customReqs['service_type'] == 'plumbing' ||
        customReqs['service_type'] == 'carpentry' ||
        customReqs['service_type'] == 'painting' ||
        customReqs['service_type'] == 'flooring'
      );
      final double basePrice = isCustomService
          ? (customReqs!['computed_price'] as num).toDouble()
          : 49.99;
      final double taxPrice = isCustomService
          ? basePrice * 0.05
          : 5.00;
      final double totalPrice = basePrice + taxPrice;

      final mockBooking = Booking(
        id: 'mock_booking_${DateTime.now().millisecondsSinceEpoch}',
        serviceId: draft.serviceId,
        packageId: draft.packageId ?? 'mock_package_id',
        providerId: 'mock_provider_id',
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        scheduledAt: draft.scheduledAt ?? DateTime.now(),
        notes: draft.notes,
        price: PriceBreakdown(
          subtotal: basePrice,
          tax: taxPrice,
          total: totalPrice,
        ),
      );
      _mockBookings.add(mockBooking);
      return mockBooking;
    }
  }

  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      await _supabase
          .from('bookings')
          .update({
            'status': 'cancelled',
            'cancellation_reason': reason,
            'cancelled_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      return true;
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
        final profileData = await _supabase
            .from('users')
            .select('*')
            .eq('id', userId)
            .maybeSingle();

        final user = SupabaseConfig.currentUser;
        if (user != null) {
          return {
            ...user.toJson(),
            'id': user.id,
            'email': user.email,
            'phone': profileData?['phone'] ?? user.phone ?? user.userMetadata?['phone'],
            'full_name': profileData?['full_name'] ?? user.userMetadata?['full_name'],
            'user_type': profileData?['user_type'],
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

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    return await _executeWithRetry<bool>(
      operation: () async {
        // 1. Safe update on public.users table (updates are allowed under standard RLS)
        try {
          await _supabase
              .from('users')
              .update(updates)
              .eq('id', userId);
        } catch (dbError) {
          log('Public users table update failed or blocked by RLS: $dbError', name: 'SupabaseService');
        }

        // 2. Sync credentials back to Supabase Auth database (always allowed under user session)
        if (phone != null || fullName != null) {
          try {
            await _supabase.auth.updateUser(
              UserAttributes(
                data: {
                  if (fullName != null) 'full_name': fullName,
                  if (phone != null) 'phone': phone,
                },
              ),
            );
          } catch (authError) {
            log('Auth database sync failed: $authError', name: 'SupabaseService');
          }
        }

        return true;
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

  // =====================================
  // PRICING CONFIGS
  // =====================================

  Future<List<PricingConfig>> getPricingConfigs() async {
    try {
      final response = await _supabase
          .from('pricing_configs')
          .select('*');
      
      final remoteConfigs = (response as List)
          .map((json) => PricingConfig.fromJson(json))
          .toList();
      
      for (final remote in remoteConfigs) {
        final index = _localPricingConfigs.indexWhere((c) => c.serviceType == remote.serviceType);
        if (index != -1) {
          _localPricingConfigs[index] = remote;
        } else {
          _localPricingConfigs.add(remote);
        }
      }
      return _localPricingConfigs;
    } catch (error) {
      log('Error fetching pricing configs: $error. Falling back to local cache.', name: 'SupabaseService');
      return _localPricingConfigs;
    }
  }

  Future<bool> updatePricingConfig(String serviceType, Map<String, dynamic> updates) async {
    final index = _localPricingConfigs.indexWhere((c) => c.serviceType == serviceType);
    if (index != -1) {
      final oldConfig = _localPricingConfigs[index];
      final newJson = oldConfig.toJson()..addAll(updates);
      _localPricingConfigs[index] = PricingConfig.fromJson(newJson);
    }

    try {
      final userId = SupabaseConfig.currentUser?.id;
      final payload = {
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
        if (userId != null) 'updated_by': userId,
      };

      await _supabase
          .from('pricing_configs')
          .update(payload)
          .eq('service_type', serviceType);
      
      return true;
    } catch (error) {
      log('Error updating pricing config: $error. Saved locally only.', name: 'SupabaseService');
      return false;
    }
  }
}
