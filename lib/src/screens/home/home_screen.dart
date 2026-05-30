import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/models/service.dart';
import 'package:ghulmil_application/src/providers/service_provider.dart';
import 'package:ghulmil_application/src/widgets/service_card.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ghulmil Services')),
      body: Padding(
        padding: const EdgeInsets.all(spacing),
        child: servicesAsync.when(
          data: (services) => _ServicesList(services: services),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _HomeErrorState(error: error),
        ),
      ),
    );
  }
}

class _ServicesList extends StatelessWidget {
  final List<Service> services;

  const _ServicesList({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const _HomeEmptyState();
    }

    return ListView.separated(
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceCard(
          id: service.id,
          title: service.title,
          subtitle: service.subtitle,
          imageUrl: service.imageUrl,
          rating: service.rating,
          tags: service.tags,
          startingPrice: _formatStartingPrice(service),
          onTap: () => context.goNamed(
            'serviceDetail',
            pathParameters: {'serviceId': service.id},
            extra: service,
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: spacing),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: spacingSm),
          Text(
            'No services available right now.',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: spacingXs),
          Text(
            "We're adding providers in your area soon. Please check back later!",
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  final Object error;

  const _HomeErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: spacingSm),
          Text(
            'Unable to load services',
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error),
          ),
          const SizedBox(height: spacingXs),
          Text(
            'Please check your connection and try again.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

String _formatStartingPrice(Service service) {
  if (service.packages.isEmpty) {
    return 'Pricing coming soon';
  }

  final lowestPrice = service.packages
      .map((package) => package.price)
      .reduce((value, element) => value < element ? value : element);

  if (lowestPrice == 0) {
    return 'Free consultation';
  }

  return '₹${lowestPrice.toStringAsFixed(0)} onwards';
}
