import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/providers/booking_details_provider.dart';
import 'package:ghulmil_application/src/widgets/booking_summary_card.dart';
import 'package:go_router/go_router.dart';

class ConfirmationScreen extends ConsumerWidget {
  final String bookingId;
  const ConfirmationScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingDetails = ref.watch(bookingDetailsProvider(bookingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed!'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: bookingDetails.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (booking) => SingleChildScrollView(
          padding: const EdgeInsets.all(spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle, color: kSuccess, size: 80),
              const SizedBox(height: spacing),
              Text(
                'You\'re booked!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: spacingSm),
              Text(
                'Provider arrives in approx. 2 days',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: spacingLg),
              BookingSummaryCard(booking: booking),
              const SizedBox(height: spacingLg),
              ElevatedButton.icon(
                onPressed: () { /* TODO: Add to calendar */ },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Add to Calendar'),
              ),
              const SizedBox(height: spacing),
              OutlinedButton.icon(
                onPressed: () { /* TODO: Contact provider */ },
                icon: const Icon(Icons.person),
                label: const Text('Contact Provider'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(spacing),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kAccent),
          onPressed: () => context.goNamed('tracking', pathParameters: {'bookingId': bookingId}),
          child: const Text('Track Job'),
        ),
      ),
    );
  }
}
