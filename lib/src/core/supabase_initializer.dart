// lib/src/core/supabase_initializer.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ghulmil_application/src/core/env_config.dart';
import 'package:ghulmil_application/src/core/supabase_config.dart';

class SupabaseInitializer {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      SupabaseConfig.logConfigurationStatus();
      EnvConfig.printConfig();

      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );

      _initialized = true;
      print('✅ Supabase initialized successfully');
    } catch (error) {
      print('❌ Failed to initialize Supabase: $error');
      print('⚠️ Please check your Supabase URL and anon key in supabase_config.dart');
      // Don't rethrow - allow app to continue
      _initialized = false;
    }
  }

  static bool get isInitialized => _initialized;

  // Test connection
  static Future<bool> testConnection() async {
    try {
      await SupabaseConfig.client
          .from('service_categories')
          .select('count')
          .single();

      print('✅ Database connection successful');
      return true;
    } catch (error) {
      print('❌ Database connection failed: $error');
      return false;
    }
  }
}
