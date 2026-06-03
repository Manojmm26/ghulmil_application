import 'package:dio/dio.dart';

class LocationGatingService {
  static final Dio _dio = Dio();

  // Launch District: Pithoragarh, Uttarakhand
  static const String launchDistrict = 'Pithoragarh';
  static const String launchState = 'Uttarakhand';

  // Pithoragarh district offline Bounding Box (Lat/Lng)
  static const double minLat = 29.20;
  static const double maxLat = 30.20;
  static const double minLng = 79.80;
  static const double maxLng = 80.50;

  // Serviced Pin Codes for Pithoragarh district (Uttarakhand)
  static const Set<String> servicedPincodes = {
    '262501', '262502', '262510', '262520', '262530', '262540'
  };

  /// Check if coordinates fall inside Pithoragarh's boundary box
  static bool isInsideBoundingBox(double lat, double lng) {
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }

  /// Check if a PIN code is active in the Pithoragarh launch zone
  static bool isPincodeServiced(String pincode) {
    final cleanPin = pincode.trim();
    return servicedPincodes.contains(cleanPin);
  }

  /// Zero-Cost Reverse Geocoding using Nominatim OpenStreetMap API
  static Future<Map<String, String>?> getAddressFromCoordinates(double lat, double lng) async {
    final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng';
    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'GhulmilApp/1.0 (contact@ghulmil.com)',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final address = response.data['address'];
        if (address != null) {
          return {
            'district': address['county'] ?? address['district'] ?? address['city_district'] ?? 'Pithoragarh',
            'state': address['state'] ?? 'Uttarakhand',
            'pincode': address['postcode'] ?? '262501',
            'suburb': address['suburb'] ?? address['neighbourhood'] ?? address['city'] ?? 'Siltham',
          };
        }
      }
    } catch (_) {}
    return null;
  }

  /// Sense device location (Mock coordinates placed in center of Pithoragarh town for demo verification)
  static Future<Map<String, double>> getDeviceLocation() async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate sensor load
    return {
      'latitude': 29.5840,  // Centroid of Pithoragarh Town
      'longitude': 80.2182,
    };
  }
}
