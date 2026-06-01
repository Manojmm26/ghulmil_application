import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/models/booking.dart';
import 'package:ghulmil_application/src/models/booking_draft.dart';
import 'package:ghulmil_application/src/models/service.dart';
import 'package:ghulmil_application/src/models/package.dart';
import 'package:ghulmil_application/src/providers/booking_provider.dart';
import 'package:ghulmil_application/src/providers/service_provider.dart';
import 'package:ghulmil_application/src/screens/service_detail/requirement_intake_screen.dart';

void main() {
  group('RequirementIntakeScreen UI Flow Tests', () {
    late Service mockService;

    setUp(() {
      mockService = const Service(
        id: 'test_service_id',
        title: 'Premium Home Deep Clean',
        subtitle: 'Reset your home with a sparkling deep clean',
        rating: 4.7,
        packages: [
          Package(
            id: 'test_package_id',
            title: 'Standard Package',
            price: 90.0,
            inclusions: ['Dusting', 'Vacuuming'],
            durationMinutes: 180,
          ),
        ],
      );
    });

    testWidgets('should update Live Estimate & UI elements when toggling Material Supply mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            serviceProvider('test_service_id').overrideWith((ref) => mockService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RequirementIntakeScreen(serviceId: 'test_service_id'),
            ),
          ),
        ),
      );

      // Let the FutureProvider complete and UI build
      await tester.pumpAndSettle();

      // --- VERIFY DEFAULT STATE (Ghulmil Supplies Materials) ---
      // Material cost should be ₹450 (1000 sqft * 0.45 * 1.0 standard factor)
      expect(find.text('Standard Material Cost'), findsOneWidget);
      expect(find.text('₹450'), findsOneWidget);
      
      // Total price should be ₹6750 (1200 base + 450 material + 5100 labor)
      expect(find.text('₹6750'), findsOneWidget);

      // Verify that quality preference cards (Standard, Semi-Premium, Premium) are visible
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Semi-Premium'), findsOneWidget);
      expect(find.text('Premium'), findsOneWidget);
      
      // Verify that the Labor-Only notice card is NOT present
      expect(find.text('Labor-Only Service Selected'), findsNothing);

      // --- TOGGLE MATERIAL MODE (Customer supplies own inventory) ---
      // Tap the "Mere paas taiyar hai" card
      final customerInventoryCard = find.text('Mere paas taiyar hai');
      expect(customerInventoryCard, findsOneWidget);
      await tester.tap(customerInventoryCard);
      
      // Re-render state updates
      await tester.pumpAndSettle();

      // --- VERIFY UPDATED STATE ---
      // Material Quality selection standard cards should now be HIDDEN
      expect(find.text('Standard'), findsNothing);
      expect(find.text('Semi-Premium'), findsNothing);
      expect(find.text('Premium'), findsNothing);

      // The "Labor-Only Service Selected" notice container should now be VISIBLE
      expect(find.text('Labor-Only Service Selected'), findsOneWidget);
      expect(find.textContaining('Please ensure bricks (eent), cement, sand (masala)'), findsOneWidget);

      // Smart Estimate should show ₹0 for material cost
      expect(find.text('Material Cost (Procured by Customer)'), findsOneWidget);
      expect(find.text('₹0'), findsOneWidget);

      // Smart Estimate Total should decrease cleanly to ₹6300 (1200 base + 0 material + 5100 labor)
      expect(find.text('₹6300'), findsOneWidget);
    });

    testWidgets('should render MEP (Electrical/Plumbing) conversational wizard and update estimates when toggling stage', (WidgetTester tester) async {
      final mepService = const Service(
        id: 'mep_service_id',
        title: 'Smart Electrical Setup',
        subtitle: 'Configure home electrical panels & devices',
        rating: 4.8,
        packages: [
          Package(
            id: 'mep_package_id',
            title: 'Express Wiring',
            price: 79.0,
            inclusions: ['Wiring', 'Audit'],
            durationMinutes: 90,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            serviceProvider('mep_service_id').overrideWith((ref) => mepService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RequirementIntakeScreen(serviceId: 'mep_service_id'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify MEP Specific Stage Title
      expect(find.text('Kaam ka Stage (Work Phase)'), findsOneWidget);
      expect(find.text('Jhirri aur Conduit'), findsOneWidget);
      expect(find.text('Fitting aur Connection'), findsOneWidget);

      // Verify default MEP live quote: base 800 + point cost 1200 (10 points * 120) + labor 4950 (1 skilled * 750 + 2 helper * 450 = 1650/day * 3 days) = 6950
      expect(find.text('₹6950'), findsOneWidget);

      // Toggle stage to "Fitting aur Connection"
      final fittingCard = find.text('Fitting aur Connection');
      expect(fittingCard, findsOneWidget);
      await tester.tap(fittingCard);
      await tester.pumpAndSettle();

      // Verify point cost recalculates to 700 (10 points * 70) and total updates to 6450
      expect(find.text('₹6450'), findsOneWidget);
    });

    testWidgets('should render Carpentry conversational wizard and update estimates when toggling furniture types', (WidgetTester tester) async {
      final carpentryService = const Service(
        id: 'carpentry_service_id',
        title: 'Custom Modular Carpentry',
        subtitle: 'Modular wardrobes & almirahs',
        rating: 4.9,
        packages: [
          Package(
            id: 'carpentry_package_id',
            title: 'Premium Sunmica Woodwork',
            price: 199.0,
            inclusions: ['Wardrobe', 'Polish'],
            durationMinutes: 300,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            serviceProvider('carpentry_service_id').overrideWith((ref) => carpentryService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RequirementIntakeScreen(serviceId: 'carpentry_service_id'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Carpentry Specific Grade Title
      expect(find.text('Kaam ka Type (Carpentry Type)'), findsOneWidget);
      expect(find.text('Laminate Wardrobe'), findsOneWidget);
      expect(find.text('Modular Kitchen'), findsOneWidget);

      // Verify default Carpentry quote: base 1500 + cabinet cost 5040 (28 sqft * 180) + labor 5250 ((1 * 850 + 2 * 450) * 3) = 11790
      expect(find.text('₹11790'), findsOneWidget);

      // Toggle to "Modular Kitchen"
      final modularKitchenCard = find.text('Modular Kitchen');
      expect(modularKitchenCard, findsOneWidget);
      await tester.tap(modularKitchenCard);
      await tester.pumpAndSettle();

      // Verify cabinet cost recalculates to 7000 (28 sqft * 250) and total updates to 13750
      expect(find.text('₹13750'), findsOneWidget);
    });

    testWidgets('should render Painting conversational wizard and update estimates when toggling wall conditions', (WidgetTester tester) async {
      final paintingService = const Service(
        id: 'painting_service_id',
        title: 'Home Wall Painting',
        subtitle: 'Full wall & ceiling painting',
        rating: 4.8,
        packages: [
          Package(
            id: 'paint_package_id',
            title: 'Standard Wall Care',
            price: 120.0,
            inclusions: ['Putty', 'Sanding'],
            durationMinutes: 180,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            serviceProvider('painting_service_id').overrideWith((ref) => paintingService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RequirementIntakeScreen(serviceId: 'painting_service_id'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Painting Specific Grade Title
      expect(find.text('Rangai ka Level (Deewar Stage)'), findsOneWidget);
      expect(find.text('Nayi Deewar (Fresh Paint)'), findsOneWidget);
      expect(find.text('Repaint / Touchup'), findsOneWidget);

      // Verify default Painting quote: base 1000 + paint cost 6000 (1000 sqft * 6.0 standard rate) + labor 5100 ((1 * 800 + 2 * 450) * 3) = 12100
      expect(find.text('₹12100'), findsOneWidget);

      // Toggle to "Repaint / Touchup"
      final repaintCard = find.text('Repaint / Touchup');
      expect(repaintCard, findsOneWidget);
      await tester.tap(repaintCard);
      await tester.pumpAndSettle();

      // Verify paint cost recalculates to 4000 (1000 sqft * 4.0 rate) and total updates to 10100
      expect(find.text('₹10100'), findsOneWidget);
    });

    testWidgets('should render Flooring conversational wizard and update estimates when toggling material options', (WidgetTester tester) async {
      final flooringService = const Service(
        id: 'flooring_service_id',
        title: 'Marble & Tile Flooring',
        subtitle: 'Premium flooring layouts',
        rating: 4.9,
        packages: [
          Package(
            id: 'floor_package_id',
            title: 'Granite Layout Premium',
            price: 250.0,
            inclusions: ['Granite', 'Ghisai'],
            durationMinutes: 360,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            serviceProvider('flooring_service_id').overrideWith((ref) => flooringService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RequirementIntakeScreen(serviceId: 'flooring_service_id'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Flooring Specific Grade Title
      expect(find.text('Flooring Material Choice'), findsOneWidget);
      expect(find.text('Ceramic / Tiles'), findsOneWidget);
      expect(find.text('Marble / Granite'), findsOneWidget);

      // Verify default Flooring quote: base 1200 + flooring cost 1000 (500 sqft * 2.0 tiles rate) + labor 5400 ((1 * 900 + 2 * 450) * 3) = 7600
      expect(find.text('₹7600'), findsOneWidget);

      // Toggle to "Marble / Granite"
      final marbleCard = find.text('Marble / Granite');
      expect(marbleCard, findsOneWidget);
      await tester.tap(marbleCard);
      await tester.pumpAndSettle();

      // Verify flooring cost recalculates to 2250 (500 sqft * 4.5 rate) and total updates to 8850
      expect(find.text('₹8850'), findsOneWidget);
    });

    testWidgets('should regress conversational steps when pressing back button and only pop on step 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            serviceProvider('test_service_id').overrideWith((ref) => mockService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RequirementIntakeScreen(serviceId: 'test_service_id'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify starting at step 0
      expect(find.text('1'), findsOneWidget);
      
      // Tap Continue to go to Step 1
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Tap Continue to go to Step 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Tap AppBar back button (leading icon)
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Should have regressed back to Step 1
      expect(find.text('Verify & Book'), findsNothing);
      expect(find.text('Continue'), findsOneWidget);

      // Tap AppBar back button again
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Should have regressed back to Step 0
      expect(find.text('Material Kaun Laayega? (Material Supply)'), findsOneWidget);
    });
  });
}
