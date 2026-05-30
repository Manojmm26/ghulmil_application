import 'package:flutter/material.dart';

/// App Constants
class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://api.ghulmil.com';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableOfflineMode = true;
  static const bool enableSupabaseConnectionTest =
      bool.fromEnvironment('ENABLE_SUPABASE_TEST_CONNECTION', defaultValue: false);
  static const bool enableDebugScreens =
      bool.fromEnvironment('ENABLE_DEBUG_SCREENS', defaultValue: false);

  // Pagination
  static const int defaultPageSize = 20;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxAddressNotesLength = 500;

  // Booking
  static const int maxRescheduleHours = 24;
  static const int maxCancellationHours = 2;

  // Maps
  static const double defaultMapZoom = 15.0;
  static const double defaultMapLat = 28.6139; // Default to Delhi coordinates
  static const double defaultMapLng = 77.2090;

  // Payment
  static const List<String> supportedCurrencies = ['INR', 'USD', 'EUR'];
  static const double maxTipPercentage = 0.2; // 20%

  // Cache
  static const Duration cacheValidity = Duration(hours: 1);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB

  // UI
  static const double borderRadius = 8.0;
  static const double maxContentWidth = 600.0;
}

/// Error Messages
class ErrorMessages {
  static const String networkError = 'Please check your internet connection';
  static const String serverError = 'Something went wrong. Please try again';
  static const String timeoutError = 'Request timed out. Please try again';
  static const String locationPermissionDenied = 'Location permission is required for accurate service';
  static const String locationServicesDisabled = 'Please enable location services';
  static const String paymentFailed = 'Payment failed. Please try another method';
  static const String bookingNotFound = 'Booking not found. Please contact support';
}

/// Success Messages
class SuccessMessages {
  static const String bookingConfirmed = 'Your booking is confirmed!';
  static const String paymentSuccessful = 'Payment processed successfully';
  static const String addressSaved = 'Address saved successfully';
  static const String reviewSubmitted = 'Thank you for your review!';
}

/// Validation Messages
class ValidationMessages {
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String addressNotesTooLong = 'Address notes cannot exceed 500 characters';
}

/// API Endpoints
class ApiEndpoints {
  static String get services => '/services';
  static String serviceById(String id) => '/services/$id';
  static String availability(String serviceId) => '/services/$serviceId/availability';
  static String bookings = '/bookings';
  static String bookingById(String id) => '/bookings/$id';
  static String payments = '/payments';
  static String tracking(String bookingId) => '/tracking/$bookingId';
  static String reviews(String bookingId) => '/reviews/$bookingId';
  static String userProfile = '/user/profile';
  static String addresses = '/user/addresses';
}

/// Storage Keys
class StorageKeys {
  static const String userToken = 'user_token';
  static const String userProfile = 'user_profile';
  static const String savedAddresses = 'saved_addresses';
  static const String paymentMethods = 'payment_methods';
  static const String recentSearches = 'recent_searches';
  static const String appLanguage = 'app_language';
  static const String onboardingComplete = 'onboarding_complete';
}

/// Analytics Events
class AnalyticsEvents {
  static const String appOpened = 'app_opened';
  static const String serviceViewed = 'service_viewed';
  static const String bookingStarted = 'booking_started';
  static const String bookingCompleted = 'booking_completed';
  static const String paymentAttempted = 'payment_attempted';
  static const String paymentCompleted = 'payment_completed';
  static const String reviewSubmitted = 'review_submitted';
  static const String searchPerformed = 'search_performed';
}

/// Asset Paths
class AssetPaths {
  static const String logo = 'assets/images/logo.png';
  static const String logoIcon = 'assets/images/logo_icon.png';
  static const String emptyState = 'assets/images/empty_state.png';
  static const String errorState = 'assets/images/error_state.png';
  static const String successState = 'assets/images/success_state.png';
}

/// Supported Locales
const List<Locale> supportedLocales = [
  Locale('en', 'US'),
  Locale('hi', 'IN'),
  Locale('es', 'ES'),
];

/// Default Locale
const Locale defaultLocale = Locale('en', 'US');
