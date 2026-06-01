import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghulmil_application/app.dart';
import 'package:ghulmil_application/src/screens/service_detail/widgets/package_card.dart';
import 'package:ghulmil_application/src/widgets/service_card.dart';
import 'package:ghulmil_application/src/core/supabase_initializer.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('should complete the full booking flow', (WidgetTester tester) async {
      // Initialize Supabase before starting the app
      await SupabaseInitializer.initialize();

      // Start the app
      await tester.pumpWidget(const ProviderScope(child: App()));
      await tester.pumpAndSettle();

      // Find the 'Premium Home Deep Clean' service card and tap it.
      final serviceCard = find.widgetWithText(ServiceCard, 'Premium Home Deep Clean');
      expect(serviceCard, findsOneWidget);
      await tester.ensureVisible(serviceCard);
      await tester.pumpAndSettle();
      await tester.tap(serviceCard);
      await tester.pumpAndSettle();

      // We are now on the ServiceDetailScreen. Find and tap the 'Book Now' button.
      // First, select a package to enable it.
      final packageCard = find.widgetWithText(PackageCard, 'Essentials Deep Clean');
      expect(packageCard, findsOneWidget);
      await tester.ensureVisible(packageCard);
      await tester.pumpAndSettle();
      await tester.tap(packageCard);
      await tester.pumpAndSettle();

      // Now the 'Book Now' button should be visible.
      final bookNowButton = find.widgetWithText(ElevatedButton, 'Book Now');
      expect(bookNowButton, findsOneWidget);
      await tester.tap(bookNowButton);
      await tester.pumpAndSettle();

      // We are on the ScheduleScreen. Select a time.
      // Let's assume the first available time slot is tappable.
      final timeSlot = find.byType(ChoiceChip).first;
      expect(timeSlot, findsOneWidget);
      await tester.tap(timeSlot);
      await tester.pumpAndSettle();

      // The 'Continue' button should now be enabled.
      final continueButton = find.widgetWithText(ElevatedButton, 'Continue');
      expect(continueButton, findsOneWidget);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // We are on the AddressScreen. Fill in the form and submit.
      final continueToPaymentButton = find.widgetWithText(ElevatedButton, 'Continue to Payment');
      expect(continueToPaymentButton, findsOneWidget);
      await tester.tap(continueToPaymentButton);
      await tester.pumpAndSettle();

      // We are on the PaymentScreen. Confirm and pay.
      final confirmAndPayButton = find.widgetWithText(ElevatedButton, 'Confirm & Pay');
      expect(confirmAndPayButton, findsOneWidget);
      await tester.tap(confirmAndPayButton);
      await tester.pumpAndSettle();

      // We should now be on the ConfirmationScreen.
      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.text('You\'re booked!'), findsOneWidget);

      // Verify the 'Track Job' button is present.
      expect(find.widgetWithText(ElevatedButton, 'Track Job'), findsOneWidget);
    });
  });
}
