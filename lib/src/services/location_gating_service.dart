import 'package:dio/dio.dart';

class LocationGatingService {
  static final Dio _dio = Dio();

  // Target Launch Info
  static const String launchDistrict = 'Gautam Buddha Nagar';
  static const String launchState = 'Uttar Pradesh';

  // गौतम बुद्ध नगर (Noida/Greater Noida) Offline Bounding Box
  static const double minLat = 28.10;
  static const double maxLat = 28.65;
  static const double minLng = 77.30;
  static const double maxLng = 77.70;

  // Serviced Pin Codes for Noida launch
  static const Set<String> servicedPincodes = {
    '201301', '201303', '201304', '201305', '201306', '201307', '201308', '201310', '201313', '201318'
  };

  /// Check if coordinates reside within the launch district bounding box
  static bool isInsideBoundingBox(double lat, double lng) {
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }

  /// Check if a postal pin code is active in our launch zone
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
            'district': address['county'] ?? address['district'] ?? address['city_district'] ?? '',
            'state': address['state'] ?? '',
            'pincode': address['postcode'] ?? '',
            'suburb': address['suburb'] ?? address['neighbourhood'] ?? address['city'] ?? '',
          };
        }
      }
    } catch (_) {}
    return null;
  }

  /// Sense device location (Mock coords in center of Noida for seamless sandbox E2E tests)
  static Future<Map<String, double>> getDeviceLocation() async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate hardware sensor lag
    return {
      'latitude': 28.5355,  // Centroid of Noida Sector 30
      'longitude': 77.3910,
    };
  }
}
