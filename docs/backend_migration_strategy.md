# =====================================
# GHULMIL APPLICATION - BACKEND MIGRATION STRATEGY
# =====================================

## Overview

This document outlines the migration strategy from the current mock-based Flutter application to a production-ready backend using Supabase. The migration will be done incrementally to minimize downtime and ensure data integrity.

## Current Status Summary

- **Supabase environment**: Configured via `lib/src/core/env_config.dart` with direct initialization in `SupabaseInitializer.initialize()`.
- **Database assets**: Schema (`docs/supabase_schema.sql`) and RLS policies (`docs/supabase_rls_policies.sql`) authored and applied to the development project.
- **Flutter integration**: Core services (`SupabaseService`, `AuthService`, `ApiClient`) now target live Supabase tables for services, bookings, profiles, and addresses.
- **Outstanding items**: Storage buckets, Edge Function deployment, monitoring stack, payments, push notifications, and real-time location tracking remain pending.

## Migration Phases

### Phase 1: Backend Setup (Week 1-2)
- [x] Set up Supabase project and configure environment
  - ✅ `SupabaseInitializer.initialize()` boots with project URL and anon key supplied through `EnvConfig`.
- [x] Create database schema and RLS policies
  - ✅ Schema and policies are defined in `docs/supabase_schema.sql` and `docs/supabase_rls_policies.sql` and loaded into the dev instance (verified via `SupabaseInitializer.testConnection()`).
- [x] Set up authentication with role-based access
  - ✅ Email/password auth implemented in `AuthService` with user-type metadata persisted to `public.users`.
- [ ] Configure storage buckets for images
  - ⏳ `SupabaseService.uploadAvatar()` and `uploadServiceImage()` are ready, but buckets (`avatars`, `service-images`) must be provisioned in Supabase.
- [ ] Deploy initial Edge Functions
  - ⏳ Edge Function drafts live in `docs/supabase_edge_functions.md`; deployment via Supabase CLI still pending.
- [ ] Set up monitoring and logging
  - ⏳ Only basic `Logger`/`dart:developer` calls exist; need centralized monitoring (e.g., Supabase Logs, Sentry).

### Phase 2: API Integration (Week 3-4)
- [x] Replace mock API client with real Supabase client
  - ✅ `lib/src/services/api_client.dart` now proxies to `SupabaseService` for all network calls.
- [x] Implement authentication flow
  - ✅ `AuthNotifier` (Riverpod) coordinates sign-in/up/out and session restoration against Supabase Auth.
- [x] Update service endpoints
  - ✅ Services, bookings, addresses, and provider queries are backed by Supabase RPC/REST in `SupabaseService`.
- [x] Implement booking creation and management
  - ✅ `SupabaseService.createBooking()` and `BookingService` persist real bookings and support cancellation updates.
- [ ] Add real-time subscriptions
  - ⏳ Booking streams (`getBookingUpdates()`, `getUserBookingsStream()`) are in place; UI wiring and broader event coverage still needed.
- [ ] Test all CRUD operations
  - ⏳ Supabase-backed unit/integration tests to be added under `test/` and `integration_test/`.

### Phase 3: Real-time Features (Week 5-6)
- [ ] Implement location tracking
  - ⏳ `TrackingService` still returns mock data; replace with Supabase real-time or Edge Function source.
- [ ] Add push notifications
  - ⏳ Notification Edge Function scaffolding exists but production delivery (FCM/APNs) not connected.
- [ ] Real-time booking status updates
  - ⏳ Requires Supabase channel subscriptions plus triggers to emit booking state transitions.
- [ ] Live provider location updates
  - ⏳ Dependent on real-time location ingestion and `find_nearby_providers` RPC wiring.
- [ ] Notification system integration
  - ⏳ Supabase `notifications` table defined; client subscription and delivery not yet implemented.

### Phase 4: Payment Integration (Week 7-8)
- [ ] Integrate Stripe payment processing
  - ⏳ Edge Function outline present; actual Stripe keys, webhook secrets, and client flows pending.
- [ ] Implement payment method management
  - ⏳ UI and Supabase table `payment_methods` need integration and secure storage setup.
- [ ] Add payment webhooks
  - ⏳ `handleWebhook` draft exists; requires deployment and secret validation.
- [ ] Handle refunds and disputes
  - ⏳ To be defined once payment processing is live.
- [ ] Test payment flows
  - ⏳ Automated and manual payment QA outstanding.

### Phase 5: Advanced Features (Week 9-10)
- [ ] Implement subscription management
  - ⏳ Database + Edge Function scaffolding in place; client flows not started.
- [ ] Add review and rating system
  - ⏳ `reviews` table ready; UI/API integration pending.
- [ ] Provider availability management
  - ⏳ Availability RPCs drafted; need calendar UI + writes.
- [ ] Analytics and reporting
  - ⏳ `getAnalytics` Edge Function planned; implementation and dashboards outstanding.
- [ ] Admin dashboard APIs
  - ⏳ Requires dedicated role endpoints and access controls.

## Technical Implementation

### 1. Supabase Client Setup

```dart
// lib/src/core/supabase_config.dart
import 'package:ghulmil_application/src/core/env_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static String get url => EnvConfig.supabaseUrl;
  static String get anonKey => EnvConfig.supabaseAnonKey;

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;
}

extension SupabaseAuth on SupabaseClient {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String userType,
  }) async {
    return await auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
        'user_type': userType,
      },
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
```

```dart
// lib/src/core/supabase_initializer.dart
class SupabaseInitializer {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }
}
```

### 2. Authentication Service

```dart
// lib/src/services/auth_service.dart
class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = SupabaseConfig.client;
  User? _currentUser;

  AuthService() {
    _supabase.auth.onAuthStateChange.listen((event, session) {
      _currentUser = session?.user;
      Logger.debug('Auth state changed: $event');
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String userType,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
        'user_type': userType,
      },
    );

    if (response.user != null) {
      await _supabase.from('users').insert({
        'id': response.user!.id,
        'email': response.user!.email,
        'full_name': response.user!.userMetadata?['full_name'] ?? '',
        'phone': response.user!.userMetadata?['phone'] ?? '',
        'user_type': userType,
      });
    }

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
```

### 3. Supabase Service Layer

```dart
// lib/src/services/supabase_service.dart
class SupabaseService {
  final _supabase = SupabaseConfig.client;

  Future<List<Service>> getServices({
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = _supabase
        .from('services')
        .select('*, service_packages(*), service_categories(*)')
        .eq('is_active', true);

    if (category != null) {
      query = query.eq('service_categories.name', category);
    }

    final response = await query
        .range(offset, offset + limit - 1)
        .order('is_featured', ascending: false)
        .order('rating', ascending: false);

    return response.map((json) => Service.fromJson(json)).toList();
  }

  Future<List<Booking>> getUserBookings({int limit = 20, int offset = 0}) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('bookings')
        .select('*, service:services(*), provider:providers(*)')
        .eq('customer_id', userId)
        .range(offset, offset + limit - 1)
        .order('created_at', ascending: false);

    return response.map((json) => Booking.fromJson(json)).toList();
  }

  Future<Booking?> createBooking(BookingDraft draft) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null || draft.address == null) return null;

    final response = await _supabase
        .from('bookings')
        .insert({
          'customer_id': userId,
          'service_id': draft.serviceId,
          'package_id': draft.packageId,
          'address_id': draft.address!.id,
          'scheduled_at': draft.scheduledAt?.toIso8601String(),
          'special_instructions': draft.notes,
        })
        .select()
        .single();

    return Booking.fromJson(response);
  }
}
```

- **High-level API**: `lib/src/services/api_client.dart` wraps `SupabaseService` and exposes typed methods for the UI layer.
- **Provider wiring**: Riverpod providers under `lib/src/providers/` (for example, `auth_provider.dart`, `booking_provider.dart`) consume this service layer.

### 4. Real-time Subscriptions

```dart
// lib/src/services/supabase_service.dart (real-time excerpts)
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
```

## Data Migration Strategy

### 1. Mock Data to Real Database

```sql
-- Migration script to populate initial data
INSERT INTO service_categories (name, description, icon_url, color, sort_order)
SELECT DISTINCT
    UNNEST(tags) as name,
    'Auto-generated from mock data' as description,
    '/icons/default.svg' as icon_url,
    CASE
        WHEN UNNEST(tags) = 'Cleaning' THEN '#0FA3B1'
        WHEN UNNEST(tags) = 'Plumbing' THEN '#FF8A00'
        ELSE '#10B981'
    END as color,
    ROW_NUMBER() OVER (ORDER BY UNNEST(tags)) as sort_order
FROM mock_services
ON CONFLICT (name) DO NOTHING;
```

### 2. User Data Migration

- Existing mock users will need to register new accounts
- User preferences and settings can be migrated via settings export/import
- Booking history will be preserved in local storage until new backend is ready

### 3. Gradual Rollout Strategy

1. **Development Environment**: Full migration for testing
2. **Beta Users**: Gradual migration with fallback to mock data
3. **Production Rollout**: Phased migration by user segments

## Testing Strategy

### 1. Unit Tests

```dart
// test/services/service_service_test.dart
void main() {
  late ServiceService serviceService;

  setUp(() {
    serviceService = ServiceService();
  });

  test('getServices returns list of services', () async {
    final services = await serviceService.getServices();

    expect(services, isA<List<Service>>());
    expect(services.length, greaterThan(0));
  });

  test('getService returns single service', () async {
    const serviceId = 'cleaning_1';
    final service = await serviceService.getService(serviceId);

    expect(service.id, equals(serviceId));
    expect(service.packages, isNotEmpty);
  });
}
```

### 2. Integration Tests

- Build end-to-end flows against Supabase dev project (pending)
- Cover authentication flows (pending)
- Cover booking creation/update/cancel (pending)
- Exercise real-time subscriptions once UI wiring completes (pending)

### 3. Performance Tests

- Load testing for API endpoints (pending)
- Real-time subscription performance (pending)
- Database query optimization (pending)
- Image upload and storage performance (blocked until buckets configured)

## Rollback Strategy

### 1. Feature Flags

> **Planned Enhancement**: Feature flags for runtime fallback control are not yet implemented. Introduce a `FeatureFlags` configuration once dual-backend support is required.

### 2. Fallback Mechanism

> **Fallback Strategy**: Continue to rely on Supabase-first execution. If mock fallback is required, implement an adapter that composes `SupabaseService` with existing mock repositories behind a shared interface.

## Deployment Checklist

- [x] Supabase project created and configured
- [x] Database schema deployed
- [x] RLS policies configured
- [ ] Edge Functions deployed
- [x] Environment variables set (via Dart defines handled by `EnvConfig`)
- [ ] Storage buckets configured
- [x] Authentication providers configured (Supabase email/password enabled)
- [ ] API keys and secrets secured (needs Secret Manager / Vault integration)
- [ ] Monitoring and logging enabled
- [ ] Backup strategy implemented
- [x] Documentation updated (this doc, `docs/supabase_*`)
- [ ] Team training completed

## Monitoring and Analytics

### 1. Performance Monitoring

- Supabase Dashboard metrics
- API response times
- Database query performance
- Real-time subscription health

### 2. Error Tracking

- Client-side error reporting
- Server-side error logging
- Failed payment tracking
- Authentication failure monitoring

### 3. Business Metrics

- User registration rates
- Booking completion rates
- Payment success rates
- Customer satisfaction scores
- Provider performance metrics

## Security Considerations

### 1. API Security

- Row Level Security enabled
- API rate limiting
- Input validation and sanitization
- SQL injection prevention

### 2. Data Protection

- PII data encryption
- Secure authentication
- Access logging
- Regular security audits

### 3. Payment Security

- PCI compliance
- Secure payment processing
- Fraud detection
- Regular security updates

## Support and Documentation

### 1. User Documentation

- API documentation updated
- Migration guide for existing users
- Troubleshooting guides
- FAQ updates

### 2. Developer Documentation

- Backend architecture documentation
- API integration guides
- Testing procedures
- Deployment instructions

### 3. Support Channels

- Technical support ticketing
- Community forums
- Developer documentation portal
- Status page for service availability
