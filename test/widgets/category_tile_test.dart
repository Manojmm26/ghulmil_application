import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghulmil_application/src/widgets/category_tile.dart';

void main() {
  group('CategoryTile Widget', () {
    testWidgets('should display label, subtitle, and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryTile(
              id: '1',
              label: 'Test Label',
              subtitle: 'Test Subtitle',
              icon: Icons.cleaning_services,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify that the label, subtitle, and icon are displayed.
      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.cleaning_services), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryTile(
              id: '1',
              label: 'Test',
              subtitle: 'Test',
              icon: Icons.ac_unit,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Tap the widget and verify that the onTap callback was called.
      await tester.tap(find.byType(CategoryTile));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
