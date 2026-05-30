import 'package:flutter/foundation.dart';

class EnvConfig {
  // Supabase configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://upduklgbkstnlrkimibk.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVwZHVrbGdia3N0bmxya2ltaWJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAxNDkyNTUsImV4cCI6MjA5NTcyNTI1NX0.owHyejScWcMmu94f6a9-djf1sYWQb2Fe1l7DS9Z6g1A',
  );

  // Environment detection
  static bool get isProduction => const String.fromEnvironment('ENVIRONMENT') == 'production';
  static bool get isDevelopment => !isProduction;

  // Validation
  static bool get isSupabaseConfigured =>
      supabaseUrl != 'https://your-project-id.supabase.co' &&
      supabaseAnonKey != 'your-anon-key-here';

  // Debug information (only show in development)
  static void printConfig() {
    if (isDevelopment) {
      debugPrint('🔧 Environment: ${isProduction ? 'Production' : 'Development'}');
      debugPrint('🔗 Supabase URL: $supabaseUrl');
      debugPrint('✅ Supabase Configured: ${isSupabaseConfigured ? 'Yes' : 'No'}');
    }
  }
}
