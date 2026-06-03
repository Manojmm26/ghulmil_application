import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/models/service.dart';
import 'package:ghulmil_application/src/providers/service_provider.dart';
import 'package:ghulmil_application/src/widgets/service_card.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isPithoragarhLocation = true; // Toggle for launch district gating demo
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.grid_view, 'color': Colors.grey},
    {'name': 'Cleaning', 'icon': Icons.cleaning_services, 'color': Color(0xFF0FA3B1)},
    {'name': 'MEP', 'icon': Icons.electrical_services, 'color': Color(0xFFFF8A00)},
    {'name': 'Carpentry', 'icon': Icons.construction, 'color': Colors.brown},
    {'name': 'Painting', 'icon': Icons.format_paint, 'color': Colors.pink},
    {'name': 'Flooring', 'icon': Icons.layers, 'color': Colors.blueGrey},
    {'name': 'Civil', 'icon': Icons.foundation, 'color': Colors.deepOrange},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesCategory(Service service, String category) {
    if (category == 'All') return true;
    final title = service.title.toLowerCase();
    final subtitle = service.subtitle?.toLowerCase() ?? '';
    final combined = '$title $subtitle';

    if (category == 'Cleaning') {
      return combined.contains('clean');
    } else if (category == 'MEP') {
      return combined.contains('electrical') || 
             combined.contains('plumbing') || 
             combined.contains('smart home') || 
             combined.contains('wire') || 
             combined.contains('leak');
    } else if (category == 'Carpentry') {
      return combined.contains('carpentry') || 
             combined.contains('wood') || 
             combined.contains('badhai');
    } else if (category == 'Painting') {
      return combined.contains('paint') || 
             combined.contains('putty') || 
             combined.contains('rangai');
    } else if (category == 'Flooring') {
      return combined.contains('flooring') || 
             combined.contains('tile') || 
             combined.contains('marble') || 
             combined.contains('ghisai');
    } else if (category == 'Civil') {
      return combined.contains('civil') || 
             combined.contains('masonry') || 
             combined.contains('concrete') || 
             combined.contains('lenter');
    }
    return false;
  }

  void _handleServiceTap(Service service) {
    if (!_isPithoragarhLocation) {
      _showEarlyAccessDrawer();
      return;
    }
    context.pushNamed(
      'serviceDetail',
      pathParameters: {'serviceId': service.id},
      extra: service,
    );
  }

  void _handleCategoryTap(String categoryName) {
    if (!_isPithoragarhLocation) {
      _showEarlyAccessDrawer();
      return;
    }
    setState(() {
      _selectedCategory = categoryName;
    });
  }

  void _showEarlyAccessDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            left: spacing,
            right: spacing,
            top: spacingLg,
            bottom: MediaQuery.of(context).viewInsets.bottom + spacingLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: SizedBox(
                  width: 40,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: spacing),
              const Icon(Icons.rocket_launch, color: kAccent, size: 60),
              const SizedBox(height: spacing),
              Text(
                'Ghulmil is Coming Soon to Your City! 🚀',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: spacingSm),
              const Text(
                'We are currently active only in Pithoragarh District (Uttarakhand) and expanding rapid-response professional Mistri services to your neighborhood soon.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kMuted, fontSize: 13),
              ),
              const SizedBox(height: spacingLg),
              Text(
                'Get Early Access & 15% Launch Discount',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: spacingSm),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter your Mobile Number or Email',
                  hintStyle: const TextStyle(color: kMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.phone_android, color: kPrimary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: spacing),
              ElevatedButton(
                onPressed: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✨ Registered! We will notify you with your 15% launch coupon code soon!'),
                      backgroundColor: kSuccess,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                child: const Text('Notify Me & Get Discount'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: kSurface,
      body: SafeArea(
        child: servicesAsync.when(
          data: (services) => _buildMainContent(services),
          loading: () => const Center(child: CircularProgressIndicator(color: kPrimary)),
          error: (error, stackTrace) => _HomeErrorState(error: error),
        ),
      ),
    );
  }

  Widget _buildMainContent(List<Service> allServices) {
    final filteredServices = allServices.where((service) {
      final matchesCat = _matchesCategory(service, _selectedCategory);
      final matchesSearch = _searchQuery.isEmpty || 
          service.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (service.subtitle?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCat && matchesSearch;
    }).toList();

    final trendingServices = allServices.where((s) => s.rating >= 4.7).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. DYNAMIC HEADER & LOCATION SELECTOR
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: spacing, vertical: spacingSm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(spacing),
                                    child: Text(
                                      'Select Service Location',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.check_circle, color: kSuccess),
                                    title: const Text('Siltham, Pithoragarh (Uttarakhand)'),
                                    subtitle: const Text('Active Service Area (100% Operations)'),
                                    trailing: _isPithoragarhLocation 
                                        ? const Icon(Icons.radio_button_checked, color: kPrimary) 
                                        : const Icon(Icons.radio_button_off),
                                    onTap: () {
                                      setState(() {
                                        _isPithoragarhLocation = true;
                                      });
                                      context.pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Switched to Siltham, Pithoragarh! All services enabled.')),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.info, color: kAccent),
                                    title: const Text('Haldwani, Uttarakhand (Nainital)'),
                                    subtitle: const Text('Launching Soon (Lead Capture Active)'),
                                    trailing: !_isPithoragarhLocation 
                                        ? const Icon(Icons.radio_button_checked, color: kPrimary) 
                                        : const Icon(Icons.radio_button_off),
                                    onTap: () {
                                      setState(() {
                                        _isPithoragarhLocation = false;
                                      });
                                      context.pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Switched to Haldwani, Uttarakhand! Location gating enabled.')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: kPrimary, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            _isPithoragarhLocation ? 'Home: Siltham, Pithoragarh' : 'Home: Haldwani, Uttarakhand',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kTextPrimary),
                          ),
                          const Icon(Icons.keyboard_arrow_down, size: 16, color: kMuted),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isPithoragarhLocation ? 'Namaste, Partner! 👋' : 'Launching Soon in Haldwani! 🚀',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kTextPrimary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, size: 26, color: kTextPrimary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notifications panel coming soon!')),
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () => context.pushNamed('profile'),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: kPrimary.withOpacity(0.1),
                        child: const Icon(Icons.person, color: kPrimary, size: 20),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),

        // 2. FLOATING SEARCH BAR
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: spacing, vertical: spacingSm),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search 'Deep Clean', 'Plumbing', 'Badhai'...",
                  hintStyle: const TextStyle(color: kMuted, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: kPrimary),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.mic, color: kMuted),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Voice input is a premium feature coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
              ),
            ),
          ),
        ),

        // 3. EMERGENCY RED-AMBER HOTLINE BANNER
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: spacing, vertical: spacingSm),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kDanger, kAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: kDanger.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (!_isPithoragarhLocation) {
                      _showEarlyAccessDrawer();
                      return;
                    }
                    context.pushNamed('emergency', pathParameters: {'serviceType': 'general'});
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: spacing, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.campaign, color: Colors.white, size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Urgent Mistri Needed? 🚨',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Book rapid-response services in 60 seconds',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 4. CURATED CATEGORIES CAROUSEL ("THE GHULMIL GRID")
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: spacing, top: spacing, bottom: spacingSm),
                child: Text(
                  'Browse Categories',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 85,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: spacing),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat['name'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _handleCategoryTap(cat['name']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? cat['color'] 
                                    : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected 
                                        ? (cat['color'] as Color).withOpacity(0.3) 
                                        : Colors.black.withOpacity(0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Icon(
                                cat['icon'],
                                color: isSelected ? Colors.white : cat['color'],
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat['name'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? kPrimary : kTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // 5. TRENDING SERVICES HORIZONTAL CAROUSEL
        if (_searchQuery.isEmpty && _selectedCategory == 'All') ...[
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: spacing, vertical: spacingSm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trending Services 🔥',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          // No-op or scroll to services list
                        },
                        child: const Text('View All', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600)),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 205,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: spacing),
                    itemCount: trendingServices.length,
                    itemBuilder: (context, index) {
                      final service = trendingServices[index];
                      return Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: spacing),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: InkWell(
                            onTap: () => _handleServiceTap(service),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (service.imageUrl != null)
                                        Image.network(service.imageUrl!, fit: BoxFit.cover)
                                      else
                                        Container(color: kPrimary.withOpacity(0.1)),
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.7),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.star, color: kAccent, size: 12),
                                              const SizedBox(width: 2),
                                              Text(
                                                service.rating.toStringAsFixed(1),
                                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(spacingSm),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          service.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kTextPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          service.subtitle ?? '',
                                          style: const TextStyle(color: kMuted, fontSize: 10),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatStartingPrice(service),
                                              style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: kPrimary.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'Best Value',
                                                style: TextStyle(color: kPrimary, fontSize: 8, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],

        // 6. ALL SERVICES / DYNAMIC CATALOG TITLE
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(spacing, spacing, spacing, spacingSm),
            child: Text(
              _selectedCategory == 'All' 
                  ? 'All Available Services' 
                  : '$_selectedCategory Services',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // 7. DYNAMIC LIST OF SERVICE CARDS
        if (filteredServices.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: _HomeEmptyState(),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: spacing),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final service = filteredServices[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: spacing),
                    child: ServiceCard(
                      id: service.id,
                      title: service.title,
                      subtitle: service.subtitle,
                      imageUrl: service.imageUrl,
                      rating: service.rating,
                      tags: service.tags,
                      startingPrice: _formatStartingPrice(service),
                      onTap: () => _handleServiceTap(service),
                    ),
                  );
                },
                childCount: filteredServices.length,
              ),
            ),
          ),

        // 8. THE GHULMIL PROMISE TRUST BADGES
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            margin: const EdgeInsets.only(top: spacingLg),
            padding: const EdgeInsets.symmetric(vertical: spacingLg, horizontal: spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.shield, color: kPrimary, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'The Ghulmil Promise 🛡️',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: spacing),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(
                      child: _TrustBadge(
                        icon: Icons.verified_user,
                        title: '100% Verified',
                        subtitle: 'Background-checked, premium Raj Mistris.',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _TrustBadge(
                        icon: Icons.currency_rupee,
                        title: 'Transparent Pricing',
                        subtitle: 'Fixed rates, zero surprise charges.',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _TrustBadge(
                        icon: Icons.history,
                        title: '15-Day Warranty',
                        subtitle: 'Free standard service re-work guarantee.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: kPrimary.withOpacity(0.1),
          child: Icon(icon, color: kPrimary, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: kTextPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: kMuted, fontSize: 8),
          textAlign: TextAlign.center,
        ),
      ],
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
            'No matching services found.',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: spacingXs),
          Text(
            "Try checking another category or refining your search keywords!",
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
