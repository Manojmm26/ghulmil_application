import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ghulmil_application/src/core/constants.dart';
import 'package:ghulmil_application/src/core/supabase_config.dart';
import 'package:ghulmil_application/src/providers/auth_provider.dart';
import 'package:ghulmil_application/src/screens/address/address_screen.dart';
import 'package:ghulmil_application/src/screens/auth/sign_in_screen.dart';
import 'package:ghulmil_application/src/screens/auth/sign_up_screen.dart';
import 'package:ghulmil_application/src/screens/auth/splash_screen.dart';
import 'package:ghulmil_application/src/screens/confirmation/confirmation_screen.dart';
import 'package:ghulmil_application/src/screens/emergency/emergency_flow_screen.dart';
import 'package:ghulmil_application/src/screens/home/home_screen.dart';
import 'package:ghulmil_application/src/screens/payment/payment_screen.dart';
import 'package:ghulmil_application/src/screens/profile/profile_screen.dart';
import 'package:ghulmil_application/src/screens/review/review_screen.dart';
import 'package:ghulmil_application/src/screens/schedule/schedule_screen.dart';
import 'package:ghulmil_application/src/screens/service_detail/service_detail_screen.dart';
import 'package:ghulmil_application/src/screens/service_detail/requirement_intake_screen.dart';
import 'package:ghulmil_application/src/screens/subscriptions/subscriptions_screen.dart';
import 'package:ghulmil_application/src/screens/test_supabase_screen.dart';
import 'package:ghulmil_application/src/screens/tracking/tracking_screen.dart';
import 'package:ghulmil_application/src/screens/admin/admin_pricing_config_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final path = state.uri.path;
    if (path.startsWith('/admin')) {
      final user = SupabaseConfig.currentUser;
      if (user == null) {
        return '/auth/signin';
      }

      // Check user metadata first (synchronous & fast)
      final userMetadataType = user.userMetadata?['user_type'];
      if (userMetadataType == 'admin') {
        return null;
      }

      // Check database profile via Riverpod if already loaded
      try {
        final container = ProviderScope.containerOf(context);
        final profileVal = container.read(userProfileProvider).value;
        if (profileVal != null) {
          if (profileVal['user_type'] == 'admin') {
            return null;
          }
          return '/home';
        }
      } catch (_) {}

      // If we cannot verify they are an admin, redirect to home to be safe
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth/signin',
      name: 'signin',
      builder: (context, state) {
        final signupSuccess = state.uri.queryParameters['signupSuccess'] == 'true';
        return SignInScreen(signupSuccess: signupSuccess);
      },
    ),
    GoRoute(
      path: '/auth/signup',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/service/:serviceId',
      name: 'serviceDetail',
      builder: (context, state) => ServiceDetailScreen(
        serviceId: state.pathParameters['serviceId']!,
      ),
    ),
    GoRoute(
      path: '/service/:serviceId/intake',
      name: 'serviceIntake',
      builder: (context, state) => RequirementIntakeScreen(
        serviceId: state.pathParameters['serviceId']!,
      ),
    ),
    GoRoute(
      path: '/schedule/:serviceId',
      name: 'schedule',
      builder: (context, state) => ScheduleScreen(
        serviceId: state.pathParameters['serviceId']!,
      ),
    ),
    GoRoute(
      path: '/address',
      name: 'address',
      builder: (context, state) => const AddressScreen(),
    ),
    GoRoute(
      path: '/payment/:bookingDraftId',
      name: 'payment',
      builder: (context, state) => PaymentScreen(
        bookingDraftId: state.pathParameters['bookingDraftId']!,
      ),
    ),
    GoRoute(
      path: '/confirmation/:bookingId',
      name: 'confirmation',
      builder: (context, state) => ConfirmationScreen(
        bookingId: state.pathParameters['bookingId']!,
      ),
    ),
    GoRoute(
      path: '/tracking/:bookingId',
      name: 'tracking',
      builder: (context, state) => TrackingScreen(
        bookingId: state.pathParameters['bookingId']!,
      ),
    ),
    GoRoute(
      path: '/review/:bookingId',
      name: 'review',
      builder: (context, state) => ReviewScreen(
        bookingId: state.pathParameters['bookingId']!,
      ),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/admin/pricing',
      name: 'adminPricing',
      builder: (context, state) => const AdminPricingConfigScreen(),
    ),
    GoRoute(
      path: '/rebook/:bookingId',
      name: 'rebook',
      // TODO: Implement QuickRebookFlow
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/subscriptions',
      name: 'subscriptions',
      builder: (context, state) => const SubscriptionsScreen(),
    ),
    GoRoute(
      path: '/emergency/:serviceType',
      name: 'emergency',
      builder: (context, state) => EmergencyFlowScreen(
        serviceType: state.pathParameters['serviceType']!,
      ),
    ),
    if (AppConstants.enableDebugScreens)
      GoRoute(
        path: '/dev/test-supabase',
        name: 'devTestSupabase',
        builder: (context, state) => const TestSupabaseScreen(),
      ),
  ],
);
