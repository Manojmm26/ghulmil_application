import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/screens/payment/payment_screen.dart';

void main() {
  group('PaymentScreen Widget', () {
    testWidgets('should render selectable payment methods', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PaymentScreen(bookingDraftId: 'test_draft'),
          ),
        ),
      );

      // Verify that all three payment options are rendered
      expect(find.text('Pay via UPI'), findsOneWidget);
      expect(find.text('Cash on Completion'), findsOneWidget);
      expect(find.text('Saved Card **** 1234'), findsOneWidget);
    });
  });
}
