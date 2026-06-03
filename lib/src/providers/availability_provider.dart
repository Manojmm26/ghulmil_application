import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/models/slot.dart';
import 'package:ghulmil_application/src/providers/api_client_provider.dart';

// A record to group the parameters for the availability provider
typedef AvailabilityParams = ({String serviceId, DateTime date});

final availabilityProvider =
    FutureProvider.autoDispose.family<List<Slot>, AvailabilityParams>((ref, params) async {
  print('DEBUG: availabilityProvider called for serviceId=${params.serviceId}, date=${params.date}');
  final apiClient = ref.watch(apiClientProvider);
  final result = await apiClient.getAvailability(params.serviceId, params.date);
  print('DEBUG: availabilityProvider returning ${result.length} slots');
  return result;
});
