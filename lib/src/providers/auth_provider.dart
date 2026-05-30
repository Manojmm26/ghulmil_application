// lib/src/providers/auth_provider.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ghulmil_application/src/services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth state - using simple state management
final authStateNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    this.user,
    required this.isLoading,
    this.error,
  });

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: true,
      error: null,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    _authService.addListener(_onAuthStateChanged);
    
    // Schedule the session check after the build is complete
    ref.onDispose(() {
      _authService.removeListener(_onAuthStateChanged);
    });
    
    // Use addPostFrameCallback to ensure we don't access state during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCurrentSession();
    });
    
    return AuthState.initial();
  }

  Future<void> _checkCurrentSession() async {
    // Don't set loading to true here since we start with loading: true in initial state
    try {
      final session = await _authService.getCurrentSession();
      if (session != null) {
        state = state.copyWith(
          isAuthenticated: true,
          user: session.user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          user: null,
          isLoading: false,
        );
      }
    } catch (error) {
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  void _onAuthStateChanged() {
    state = state.copyWith(
      user: _authService.currentUser,
      isAuthenticated: _authService.isAuthenticated,
    );
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.signIn(email: email, password: password);
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String userType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        userType: userType,
      );

      // After successful signup, check if user is now authenticated
      // Supabase typically creates a session immediately after signup
      final session = await _authService.getCurrentSession();
      if (session != null) {
        state = state.copyWith(
          isAuthenticated: true,
          user: session.user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.signInWithGoogle();
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.signOut();
      state = state.copyWith(
        isAuthenticated: false,
        user: null,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
