# Development Roadmap

## Overview
This document tracks the implementation progress of the core customer booking experience for the Ghulmil application. It focuses on building the MVP customer journey first, then layering supporting capabilities.

## Milestones

### Milestone 1 · Platform Foundation (Week 1–2)
- [x] Initialize `SupabaseInitializer.initialize()` on app boot (blocker: ensure credentials via `dart-define`)
- [x] Implement auth session persistence using `AuthNotifier` (splash gate in `lib/app.dart`)
- [x] Add debug route for `TestSupabaseScreen` guarded by build flag

### Milestone 2 · Authentication & Onboarding (Week 2)
- [x] Splash/loading screen that waits for Supabase initialization
- [x] Sign-in screen (email + password)
- [x] Sign-up screen capturing full name, phone, and user type
- [x] Supabase user-profile RLS policies and trigger-driven profile creation

### Milestone 3 · Service Discovery (Week 3)
- [ ] Fetch services via `ApiClient.getServices()` and populate `HomeScreen`
- [ ] Service detail screen with packages and CTA to schedule
- [ ] Category filters and featured highlights

### Milestone 4 · Booking Pipeline (Week 3–4)
- [ ] Schedule screen with availability picker driven by `ApiClient.getAvailability()`
- [ ] Address entry/selection integrating `ApiClient.createAddress()` & `getUserAddresses()`
- [ ] Payment review screen with price breakdown (temporary mock payment submission)
- [ ] Confirmation screen showing booking summary and provider details

### Milestone 5 · Post-Booking Essentials (Week 4–5)
- [ ] Booking history list using `ApiClient.getUserBookings()`
- [ ] Basic tracking screen showing booking state updates
- [ ] Review prompt scaffolding (UI-only)

### Milestone 6 · Enhancements & Polish (Week 6+)
- [ ] Replace mock payment with real gateway integration
- [ ] Expand tracking with live location updates
- [ ] Implement review submission flow with Supabase mutations
- [ ] Refine subscriptions and emergency screens

## Next Actions
- **Milestone 3 kickoff**: Implement `ApiClient.getServices()` and display results on `HomeScreen`.
- **Design service detail flow**: Outline data contract for packages and scheduling CTA.
- **Prepare booking pipeline**: Draft API interfaces for availability, addresses, and payment review.

## Backlog & Notes
- Quick rebook flow (`routes.dart` TODO)
- Provider/admin tooling will be scoped after customer MVP is stable
- Add more diagnostics to `TestSupabaseScreen` as APIs mature
