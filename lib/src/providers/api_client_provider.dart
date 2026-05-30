import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/services/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
