// lib/src/screens/test_supabase_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/providers/auth_provider.dart';
import 'package:ghulmil_application/src/services/api_client.dart';
import 'package:ghulmil_application/src/providers/api_client_provider.dart';

class TestSupabaseScreen extends ConsumerWidget {
  const TestSupabaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    final apiClient = ref.watch(apiClientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Integration Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auth Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Authentication Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Loading: ${authState.isLoading}'),
                    Text('Authenticated: ${authState.isAuthenticated}'),
                    if (authState.user != null)
                      Text('User ID: ${authState.user!.id}'),
                    if (authState.error != null)
                      Text('Error: ${authState.error}', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Buttons
            ElevatedButton(
              onPressed: authState.isLoading ? null : () => _testServices(context, apiClient),
              child: const Text('Test Services API'),
            ),

            ElevatedButton(
              onPressed: authState.isLoading ? null : () => _testBookings(context, apiClient),
              child: const Text('Test Bookings API'),
            ),

            ElevatedButton(
              onPressed: () => _testSignOut(context, ref),
              child: const Text('Sign Out'),
            ),

            const SizedBox(height: 16),

            // Connection Status
            FutureBuilder<bool>(
              future: _testDatabaseConnection(apiClient),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                return Card(
                  color: snapshot.data == true ? Colors.green[50] : Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          snapshot.data == true ? Icons.check_circle : Icons.error,
                          color: snapshot.data == true ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          snapshot.data == true
                              ? 'Database Connected Successfully!'
                              : 'Database Connection Failed',
                          style: TextStyle(
                            color: snapshot.data == true ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testServices(BuildContext context, ApiClient apiClient) async {
    try {
      final services = await apiClient.getServices();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${services.length} services'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Services Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testBookings(BuildContext context, ApiClient apiClient) async {
    try {
      final bookings = await apiClient.getUserBookings();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${bookings.length} bookings'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bookings Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _testSignOut(BuildContext context, WidgetRef ref) {
    ref.read(authStateNotifierProvider.notifier).signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signed out successfully'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<bool> _testDatabaseConnection(ApiClient apiClient) async {
    try {
      final services = await apiClient.getServices();
      return services.isNotEmpty;
    } catch (error) {
      return false;
    }
  }
}
