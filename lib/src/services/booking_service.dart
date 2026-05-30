import 'package:ghulmil_application/src/models/booking.dart';
import 'package:ghulmil_application/src/models/booking_draft.dart';
import 'package:ghulmil_application/src/services/api_client.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService(this._apiClient);

  Future<Booking> createBooking(BookingDraft draft) async {
    final result = await _apiClient.createBooking(draft);
    if (result == null) {
      throw Exception('Failed to create booking');
    }
    return result;
  }
}
