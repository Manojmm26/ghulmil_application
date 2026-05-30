import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/models/slot.dart';
import 'package:ghulmil_application/src/providers/api_client_provider.dart';

// A record to group the parameters for the availability provider
typedef AvailabilityParams = ({String serviceId, DateTime date});

final availabilityProvider =
    FutureProvider.family<List<Slot>, AvailabilityParams>((ref, params) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.getAvailability(params.serviceId, params.date);
});
