import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/models/pricing_config.dart';
import 'package:ghulmil_application/src/providers/api_client_provider.dart';

class PricingConfigNotifier extends AsyncNotifier<List<PricingConfig>> {
  @override
  Future<List<PricingConfig>> build() async {
    final apiClient = ref.watch(apiClientProvider);
    return apiClient.getPricingConfigs();
  }

  Future<bool> updateRates(String serviceType, Map<String, dynamic> rates) async {
    final apiClient = ref.read(apiClientProvider);
    final success = await apiClient.updatePricingConfig(serviceType, rates);
    if (success) {
      ref.invalidateSelf();
    }
    return success;
  }
}

final pricingConfigProvider = AsyncNotifierProvider.autoDispose<PricingConfigNotifier, List<PricingConfig>>(
  PricingConfigNotifier.new,
);
