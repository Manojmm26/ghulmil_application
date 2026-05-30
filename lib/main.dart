import 'package:flutter/material.dart';
import 'package:ghulmil_application/app.dart';
import 'package:ghulmil_application/src/core/constants.dart';
import 'package:ghulmil_application/src/core/supabase_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseInitializer.initialize();
    // Test connection if initialization was successful and feature flag enabled
    if (SupabaseInitializer.isInitialized && AppConstants.enableSupabaseConnectionTest) {
      await SupabaseInitializer.testConnection();
    }
  } catch (error) {
    print('Failed to initialize Supabase: $error');
    // Continue with app startup - features will show error states
  }

  runApp(const App());
}
