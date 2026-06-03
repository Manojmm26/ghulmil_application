import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/providers/tracking_provider.dart';
import 'package:ghulmil_application/src/widgets/provider_card.dart';
import 'package:go_router/go_router.dart';

class TrackingScreen extends ConsumerWidget {
  final String bookingId;
  const TrackingScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingInfo = ref.watch(trackingProvider(bookingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Your Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Home',
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Go to Main Menu',
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Premium styled abstract vector map mock placeholder (Offline & Test compatible)
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF3F7FA), // Soft light-blue slate background
            ),
            child: Stack(
              children: [
                // Render offline mock map grid lines
                Positioned.fill(
                  child: GridPaper(
                    color: kPrimary.withOpacity(0.04),
                    interval: 60.0,
                    divisions: 2,
                    subdivisions: 1,
                  ),
                ),
                // Centered map indicators
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: kPrimary.withOpacity(0.15), width: 2),
                        ),
                        child: const Icon(Icons.map_outlined, size: 48, color: kPrimary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pithoragarh Town Center Map',
                        style: TextStyle(
                          color: kTextPrimary.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Live tracking system active',
                        style: TextStyle(
                          color: kMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          trackingInfo.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (locationUpdate) => Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Provider is ${locationUpdate.etaMinutes} minutes away',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: kTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: spacingSm),
                  ProviderCard(
                    id: 'prov_123',
                    name: 'John Doe',
                    photoUrl: 'https://placehold.co/150/0FA3B1/FFFFFF/png?text=JD',
                    rating: 4.8,
                    verified: true,
                    languages: const ['English', 'Spanish'],
                    onCall: () {},
                    onMessage: () {},
                  ),
                  const SizedBox(height: spacingSm),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: kPrimary,
                      side: const BorderSide(color: kPrimary, width: 2),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text(
                      'Go to Main Menu',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
