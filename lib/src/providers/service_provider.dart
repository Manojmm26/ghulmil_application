import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/models/service.dart';
import 'package:ghulmil_application/src/providers/api_client_provider.dart';

final servicesProvider = FutureProvider.autoDispose<List<Service>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.getServices();
});

final serviceProvider = FutureProvider.autoDispose.family<Service, String>((ref, serviceId) async {
  final apiClient = ref.watch(apiClientProvider);
  final result = await apiClient.getService(serviceId);
  if (result == null) {
    throw Exception('Service not found');
  }
  return result;
});
