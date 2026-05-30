import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/models/service.dart';
import 'package:ghulmil_application/src/providers/booking_provider.dart';
import 'package:ghulmil_application/src/providers/service_provider.dart';
import 'package:ghulmil_application/src/screens/service_detail/widgets/package_card.dart';
import 'package:go_router/go_router.dart';

class ServiceDetailScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final Service? initialService;

  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
    this.initialService,
  });

  @override
  ConsumerState<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Start a new booking draft when the screen is initialized.
    Future.microtask(() => ref.read(bookingDraftProvider.notifier).startDraft(widget.serviceId));
  }

  @override
  Widget build(BuildContext context) {
    final serviceAsync = ref.watch(serviceProvider(widget.serviceId));
    final bookingDraft = ref.watch(bookingDraftProvider);
    final bookingNotifier = ref.read(bookingDraftProvider.notifier);

    final service = serviceAsync.maybeWhen(
      data: (data) => data,
      orElse: () => widget.initialService,
    );

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (service == null && serviceAsync.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service == null) {
            return _ServiceErrorState(
              error: serviceAsync.error,
              onRetry: () => ref.invalidate(serviceProvider(widget.serviceId)),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(serviceProvider(widget.serviceId).future),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      service.title,
                      style: const TextStyle(
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
                      ),
                    ),
                    background: _ServiceHeaderImage(imageUrl: service.imageUrl, title: service.title),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(spacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.title, style: Theme.of(context).textTheme.headlineMedium),
                        if (service.subtitle != null) ...[
                          const SizedBox(height: spacingSm),
                          Text(service.subtitle!, style: Theme.of(context).textTheme.bodyLarge),
                        ],
                        const SizedBox(height: spacing),
                        Row(
                          children: [
                            const Icon(Icons.star, color: kAccent, size: 20),
                            const SizedBox(width: spacingXs),
                            Text(service.rating.toStringAsFixed(1), style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                        if (service.tags.isNotEmpty) ...[
                          const SizedBox(height: spacingSm),
                          Wrap(
                            spacing: spacingXs,
                            runSpacing: spacingXs,
                            children: service.tags
                                .map(
                                  (tag) => Chip(
                                    label: Text(tag),
                                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                                    labelStyle: Theme.of(context).textTheme.bodySmall,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: spacing),
                        Text('Packages', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                ),
                if (service.packages.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 300,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: spacing),
                        itemCount: service.packages.length,
                        separatorBuilder: (context, index) => const SizedBox(width: spacing),
                        itemBuilder: (context, index) {
                          final package = service.packages[index];
                          return SizedBox(
                            width: 260,
                            child: PackageCard(
                              id: package.id,
                              title: package.title,
                              duration: Duration(minutes: package.durationMinutes),
                              price: package.price,
                              inclusions: package.inclusions,
                              isSelected: bookingDraft?.packageId == package.id,
                              onSelect: () => bookingNotifier.setPackage(package.id),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: spacing),
                      child: _EmptyPackagesState(serviceTitle: service.title),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: spacingLg)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: bookingDraft?.packageId != null
          ? SafeArea(
              minimum: const EdgeInsets.all(spacing),
              child: ElevatedButton(
                onPressed: () => context.goNamed(
                  'schedule',
                  pathParameters: {'serviceId': widget.serviceId},
                ),
                child: const Text('Book Now'),
              ),
            )
          : null,
    );
  }
}

class _ServiceHeaderImage extends StatelessWidget {
  final String? imageUrl;
  final String title;

  const _ServiceHeaderImage({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported, color: Theme.of(context).colorScheme.outline, size: 48),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.error, size: 48),
      ),
    );
  }
}

class _ServiceErrorState extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _ServiceErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(spacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: spacingSm),
            Text(
              'Unable to load service details',
              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: spacingXs),
            if (error != null)
              Text(
                '$error',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: spacing),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPackagesState extends StatelessWidget {
  final String serviceTitle;

  const _EmptyPackagesState({required this.serviceTitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Packages coming soon',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: spacingXs),
          Text(
            'We are curating package options for $serviceTitle. Please check back shortly.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
