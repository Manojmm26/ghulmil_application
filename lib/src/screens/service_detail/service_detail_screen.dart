import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/models/service.dart';
import 'package:ghulmil_application/src/providers/booking_provider.dart';
import 'package:ghulmil_application/src/providers/service_provider.dart';
import 'package:ghulmil_application/src/providers/pricing_provider.dart';
import 'package:ghulmil_application/src/models/pricing_config.dart';
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
    Future.microtask(() {
      ref.read(bookingDraftProvider.notifier).startDraft(widget.serviceId);
      ref.invalidate(pricingConfigProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(pricingConfigProvider);
    final serviceAsync = ref.watch(serviceProvider(widget.serviceId));
    final bookingDraft = ref.watch(bookingDraftProvider);
    final bookingNotifier = ref.read(bookingDraftProvider.notifier);
    final theme = Theme.of(context);

    final service = serviceAsync.maybeWhen(
      data: (data) => data,
      orElse: () => widget.initialService,
    );

    final isConstruction = service != null && (
      service.title.toLowerCase().contains('structure') ||
      service.title.toLowerCase().contains('electrical') ||
      service.title.toLowerCase().contains('plumbing') ||
      service.title.toLowerCase().contains('masonry') ||
      service.title.toLowerCase().contains('carpentry') ||
      service.title.toLowerCase().contains('painting') ||
      service.title.toLowerCase().contains('paint') ||
      service.title.toLowerCase().contains('tile') ||
      service.title.toLowerCase().contains('flooring') ||
      service.title.toLowerCase().contains('marble') ||
      service.title.toLowerCase().contains('granite') ||
      service.title.toLowerCase().contains('wood') ||
      service.title.toLowerCase().contains('civil') ||
      service.title.toLowerCase().contains('clean')
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
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),
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
                        if (isConstruction) ...[
                          const SizedBox(height: spacingLg),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.engineering_outlined, color: theme.colorScheme.secondary, size: 28),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Standard Fixed-Wage Service',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'This service is billed dynamically based on standard local daily wages (Raj Mistri & Beldar) and materials configured by you. Click below to customize your team and get a smart live estimate.',
                                        style: TextStyle(fontSize: 12, height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: spacingLg),
                        Text(isConstruction ? 'Labour & Service Highlights' : 'Packages', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                ),
                if (isConstruction)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: spacing),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLaborRatesSection(context, theme, service),
                          const SizedBox(height: spacingLg),
                          _buildGhulmilPromisesSection(context, theme),
                        ],
                      ),
                    ),
                  )
                else if (service.packages.isNotEmpty)
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
      bottomNavigationBar: (isConstruction || bookingDraft?.packageId != null)
          ? SafeArea(
              minimum: const EdgeInsets.all(spacing),
              child: ElevatedButton(
                onPressed: () {
                  if (isConstruction) {
                    context.pushNamed(
                      'serviceIntake',
                      pathParameters: {'serviceId': widget.serviceId},
                    );
                  } else {
                    context.pushNamed(
                      'schedule',
                      pathParameters: {'serviceId': widget.serviceId},
                    );
                  }
                },
                child: Text(isConstruction ? 'Configure Requirements' : 'Book Now'),
              ),
            )
          : null,
    );
  }

  String _getServiceType(Service service) {
    final title = service.title.toLowerCase();
    if (title.contains('electrical') || title.contains('wire') || title.contains('bijli')) {
      return 'electrical';
    } else if (title.contains('plumbing') || title.contains('sanitary') || title.contains('leak') || title.contains('pipe')) {
      return 'plumbing';
    } else if (title.contains('carpentry') || title.contains('wood') || title.contains('furniture') || title.contains('wardrobe') || title.contains('kitchen') || title.contains('cabinet')) {
      return 'carpentry';
    } else if (title.contains('painting') || title.contains('paint') || title.contains('putty') || title.contains('wall')) {
      return 'painting';
    } else if (title.contains('tile') || title.contains('flooring') || title.contains('marble') || title.contains('granite')) {
      return 'flooring';
    } else if (title.contains('clean')) {
      return 'civil';
    } else {
      return 'civil';
    }
  }

  PricingConfig _getPricingConfig(String serviceType) {
    final list = ref.watch(pricingConfigProvider).value;
    if (list != null) {
      return list.firstWhere(
        (c) => c.serviceType == serviceType,
        orElse: () => _getDefaultFallback(serviceType),
      );
    }
    return _getDefaultFallback(serviceType);
  }

  PricingConfig _getDefaultFallback(String serviceType) {
    if (serviceType == 'electrical') {
      return const PricingConfig(
        serviceType: 'electrical',
        baseRate: 800.0,
        mistriDailyWage: 750.0,
        beldarDailyWage: 450.0,
      );
    } else if (serviceType == 'plumbing') {
      return const PricingConfig(
        serviceType: 'plumbing',
        baseRate: 900.0,
        mistriDailyWage: 800.0,
        beldarDailyWage: 450.0,
      );
    } else if (serviceType == 'carpentry') {
      return const PricingConfig(
        serviceType: 'carpentry',
        baseRate: 1500.0,
        mistriDailyWage: 850.0,
        beldarDailyWage: 450.0,
      );
    } else if (serviceType == 'painting') {
      return const PricingConfig(
        serviceType: 'painting',
        baseRate: 1000.0,
        mistriDailyWage: 800.0,
        beldarDailyWage: 450.0,
      );
    } else if (serviceType == 'flooring') {
      return const PricingConfig(
        serviceType: 'flooring',
        baseRate: 1200.0,
        mistriDailyWage: 900.0,
        beldarDailyWage: 450.0,
      );
    } else {
      return const PricingConfig(
        serviceType: 'civil',
        baseRate: 1200.0,
        mistriDailyWage: 800.0,
        beldarDailyWage: 450.0,
      );
    }
  }

  Widget _buildLaborRatesSection(BuildContext context, ThemeData theme, Service service) {
    final serviceType = _getServiceType(service);
    final config = _getPricingConfig(serviceType);

    String skilledTitle = 'Skilled Raj Mistri (Mason)';
    String helperTitle = 'Helper (Unskilled Beldar)';

    if (serviceType == 'electrical') {
      skilledTitle = 'Skilled Electrician';
    } else if (serviceType == 'plumbing') {
      skilledTitle = 'Skilled Plumber';
    } else if (serviceType == 'carpentry') {
      skilledTitle = 'Skilled Badhai (Carpenter)';
    } else if (serviceType == 'painting') {
      skilledTitle = 'Skilled Painter';
    } else if (serviceType == 'flooring') {
      skilledTitle = 'Skilled Flooring Mistri';
    }

    final skilledRate = '₹${config.mistriDailyWage.toStringAsFixed(0)} / Day';
    final helperRate = '₹${config.beldarDailyWage.toStringAsFixed(0)} / Day';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: kPrimary.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.currency_rupee, color: kPrimary, size: 24),
              const SizedBox(width: spacingSm),
              Text(
                'Fixed Local Labour Rates',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: spacingSm),
          Text(
            'Transparent, direct billing based on standardized wage guidelines for Pithoragarh District. No markups, no hidden costs.',
            style: theme.textTheme.bodySmall?.copyWith(color: kMuted),
          ),
          const Divider(height: spacingLg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skilledTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kTextPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text('High-precision structural & technical tasks', style: TextStyle(color: kMuted, fontSize: 10)),
                  ],
                ),
              ),
              Text(
                skilledRate,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimary),
              ),
            ],
          ),
          const SizedBox(height: spacing),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      helperTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kTextPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text('Material mixing, cleanup, curing & support', style: TextStyle(color: kMuted, fontSize: 10)),
                  ],
                ),
              ),
              Text(
                helperRate,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGhulmilPromisesSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ghulmil Promises & Service Quality 🛡️',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: spacingSm),
        const Text(
          'Enjoy peace of mind with our standardized professional guarantees for all local labor tasks.',
          style: TextStyle(color: kMuted, fontSize: 12),
        ),
        const SizedBox(height: spacing),

        _buildPromiseCard(
          context,
          Icons.gpp_good_outlined,
          'Background Verified Workforce',
          'Every Raj Mistri, Badhai, Electrician & Beldar is background checked, identity verified, and local to Pithoragarh.',
        ),
        const SizedBox(height: spacingSm),
        _buildPromiseCard(
          context,
          Icons.construction_outlined,
          'Heavy Tooling & Machinery Included',
          'Standard equipment (hammer drills, wall cutters, grinders, scaffolding tools) are provided by the crew at no extra rent.',
        ),
        const SizedBox(height: spacingSm),
        _buildPromiseCard(
          context,
          Icons.receipt_long_outlined,
          'Itemized Digital Invoices',
          'Complete transparent tracking of days worked and materials supplied, sent directly to your phone with zero middleman markup.',
        ),
        const SizedBox(height: spacingSm),
        _buildPromiseCard(
          context,
          Icons.handshake_outlined,
          'Workforce Scale Flexibility',
          'Need to speed up? Easily increase/decrease workforce counts or add helpers anytime directly through our booking agent.',
        ),
      ],
    );
  }

  Widget _buildPromiseCard(BuildContext context, IconData icon, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(spacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: kPrimary.withOpacity(0.08),
            child: Icon(icon, color: kPrimary, size: 22),
          ),
          const SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kTextPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: kMuted, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
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
