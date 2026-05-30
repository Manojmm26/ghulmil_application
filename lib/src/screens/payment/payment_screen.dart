import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/providers/booking_provider.dart';
import 'package:go_router/go_router.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String bookingDraftId;
  const PaymentScreen({super.key, required this.bookingDraftId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isLoading = false;

  Future<void> _confirmAndPay() async {
    setState(() {
      _isLoading = true;
    });

    final bookingNotifier = ref.read(bookingDraftProvider.notifier);
    final newBooking = await bookingNotifier.commitBooking();

    if (mounted) {
      if (newBooking != null) {
        context.goNamed('confirmation', pathParameters: {'bookingId': newBooking.id});
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingDraft = ref.watch(bookingDraftProvider);

    if (bookingDraft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: const Center(
          child: Text('Booking session expired. Please start over.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price Breakdown', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: spacing),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(spacing),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Standard Clean'),
                        Text('\$49.99'),
                      ],
                    ),
                    const SizedBox(height: spacingSm),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Taxes & Fees'),
                        Text('\$5.00'),
                      ],
                    ),
                    const Divider(height: spacing * 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: Theme.of(context).textTheme.titleMedium),
                        Text('\$54.99', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: kPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: spacingLg),
            Text('Payment Options', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: spacing),
            // Mock payment options
            RadioListTile(title: const Text('Saved Card **** 1234'), value: 1, groupValue: 1, onChanged: (v) {}),
            RadioListTile(title: const Text('Cash on Completion'), value: 2, groupValue: 1, onChanged: (v) {}),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(spacing),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _confirmAndPay,
          child: _isLoading
              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
              : const Text('Confirm & Pay'),
        ),
      ),
    );
  }
}
