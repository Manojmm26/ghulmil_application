import 'package:flutter/material.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/models/booking.dart';
import 'package:intl/intl.dart';

class BookingSummaryCard extends StatelessWidget {
  final Booking booking;

  const BookingSummaryCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking ID: ${booking.id}', style: Theme.of(context).textTheme.bodySmall),
            const Divider(height: spacing * 2),
            _buildDetailRow(context, Icons.event, 'Scheduled for', DateFormat.yMMMd().add_jm().format(booking.scheduledAt!)),
            const SizedBox(height: spacing),
            _buildDetailRow(context, Icons.construction, 'Service', booking.serviceId.replaceAll('_', ' ').toUpperCase()),
            const SizedBox(height: spacing),
            _buildDetailRow(context, Icons.person, 'Provider', 'Provider arriving soon'), // Placeholder
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: kMuted, size: 20),
        const SizedBox(width: spacing),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}
