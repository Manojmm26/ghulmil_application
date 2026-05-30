// lib/src/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ghulmil_application/src/core/supabase_config.dart';

// Simple logger for development
import 'package:ghulmil_application/src/core/logger.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = SupabaseConfig.client;
  User? _currentUser;

  AuthService() {
    _initializeAuthListener();
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  void _initializeAuthListener() {
    _supabase.auth.onAuthStateChange.listen((authState) {
      _currentUser = authState.session?.user;
      Logger.debug('Auth state changed: ${authState.event}');
      notifyListeners();
    });
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String userType,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'user_type': userType,
        },
      );

      return response;
    } catch (error) {
      Logger.error('Sign up error: $error');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      Logger.error('Sign in error: $error');
      rethrow;
    }
  }

  // Sign in with Google
  Future<dynamic> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // On Web, use Supabase OAuth redirect which doesn't require local Google Sign-In client setup.
        // It redirects directly to Google via Supabase, then returns back to our app.
        final success = await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kDebugMode ? 'http://localhost:5030/' : null,
        );
        return success;
      }

      // For native platforms (Android/iOS), use GoogleSignIn package
      const webClientId = ''; // You'll need to add your web client ID here
      const iosClientId = ''; // You'll need to add your iOS client ID here
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId.isEmpty ? null : iosClientId,
        serverClientId: webClientId.isEmpty ? null : webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw Exception('No Access Token found');
      }
      if (idToken == null) {
        throw Exception('No ID Token found');
      }

      // Sign in to Supabase with the Google tokens
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response;
    } catch (error) {
      Logger.error('Google sign in error: $error');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (error) {
      Logger.error('Sign out error: $error');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.ghulmil.application://reset-password/',
      );
    } catch (error) {
      Logger.error('Reset password error: $error');
      rethrow;
    }
  }

  // Get user profile from database
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();

      return response;
    } catch (error) {
      Logger.error('Error fetching user profile: $error');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final userId = _currentUser?.id;
      if (userId == null) return false;

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId);

      return response.error == null;
    } catch (error) {
      Logger.error('Error updating user profile: $error');
      return false;
    }
  }

  // Get session status
  Future<Session?> getCurrentSession() async {
    try {
      final session = _supabase.auth.currentSession;
      return session;
    } catch (error) {
      Logger.error('Error getting session: $error');
      return null;
    }
  }
}
