// lib/src/core/supabase_config.dart
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ghulmil_application/src/core/env_config.dart';

class SupabaseConfig {
  static String get url => EnvConfig.supabaseUrl;
  static String get anonKey => EnvConfig.supabaseAnonKey;

  static SupabaseClient get client => Supabase.instance.client;

  // Helper methods
  static User? get currentUser => client.auth.currentUser;

  static bool get isAuthenticated => currentUser != null;

  static bool get isConfigured => EnvConfig.isSupabaseConfigured;

  static void logConfigurationStatus() {
    if (!isConfigured) {
      log(
        'Supabase configuration is missing. Update dart-define values for SUPABASE_URL and SUPABASE_ANON_KEY.',
        name: 'SupabaseConfig',
        level: 900,
      );
    }
  }

  static Future<bool> refreshSession() async {
    try {
      final response = await client.auth.refreshSession();
      return response.session != null;
    } catch (error) {
      log('Error refreshing session: $error', name: 'SupabaseConfig');
      return false;
    }
  }
}

// Extension methods for Supabase client
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
    return await auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
