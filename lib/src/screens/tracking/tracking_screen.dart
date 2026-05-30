import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/providers/tracking_provider.dart';
import 'package:ghulmil_application/src/widgets/provider_card.dart';

class TrackingScreen extends ConsumerWidget {
  final String bookingId;
  const TrackingScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingInfo = ref.watch(trackingProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Track Your Service')),
      body: Stack(
        children: [
          // Placeholder for MapWidget
          Container(
            color: Colors.grey[300],
            child: const Center(child: Text('Map Placeholder')),
          ),
          trackingInfo.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (locationUpdate) => Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text('Provider is ${locationUpdate.etaMinutes} minutes away',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(backgroundColor: Colors.white.withOpacity(0.7))),
                  const SizedBox(height: spacing),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
