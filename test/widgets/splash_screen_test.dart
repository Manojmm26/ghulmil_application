import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghulmil_application/src/screens/auth/splash_screen.dart';

void main() {
  group('SplashScreen Widget', () {
    testWidgets('should render logo, wordmark, and localized subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify that the Wordmark 'GHULMIL' is displayed
      expect(find.text('GHULMIL'), findsOneWidget);

      // Verify that the Subtitle is displayed
      expect(find.text("Pithoragarh's Premium Handyman"), findsOneWidget);

      // Verify that the logo image asset is rendered
      expect(find.byType(Image), findsOneWidget);

      // Drain the transition timer to avoid "Timer is still pending" errors
      await tester.pump(const Duration(milliseconds: 2500));
    });
  });
}
