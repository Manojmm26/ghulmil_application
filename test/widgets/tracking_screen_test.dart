import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/screens/tracking/tracking_screen.dart';

void main() {
  group('TrackingScreen Widget', () {
    testWidgets('should render navigation controls and Pithoragarh mock map', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TrackingScreen(bookingId: 'test_booking'),
          ),
        ),
      );

      // Verify that the title and Pithoragarh town center map placeholder are displayed
      expect(find.text('Track Your Service'), findsOneWidget);
      expect(find.text('Pithoragarh Town Center Map'), findsOneWidget);

      // Verify the home icon action button is rendered
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);

      // Verify the back arrow leading button is rendered
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
