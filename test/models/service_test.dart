import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghulmil_application/src/models/service.dart';

void main() {
  group('Service Model', () {
    test('should correctly serialize to and from JSON', () {
      final mockServiceJson = {
        'id': 'cleaning_1',
        'title': 'Household Cleaning',
        'subtitle': 'Professional cleaning for your home',
        'rating': 4.7,
        'tags': ['Cleaning', 'Home', 'Verified'],
        'image_url': 'https://example.com/image.png',
        'packages': [], // Using an empty list to simplify the test
      };

      // From JSON
      final service = Service.fromJson(mockServiceJson);

      expect(service.id, 'cleaning_1');
      expect(service.title, 'Household Cleaning');
      expect(service.rating, 4.7);
      expect(service.packages, isEmpty);

      // To JSON
      final generatedJson = service.toJson();

      // Normalize both maps by encoding and decoding to ensure key order doesn't matter.
      final normalizedGeneratedJson = jsonDecode(jsonEncode(generatedJson));
      final normalizedMockServiceJson = jsonDecode(jsonEncode(mockServiceJson));

      expect(normalizedGeneratedJson, normalizedMockServiceJson);
    });
  });
}
