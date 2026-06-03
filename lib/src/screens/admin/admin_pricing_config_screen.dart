import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/models/pricing_config.dart';
import 'package:ghulmil_application/src/providers/pricing_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPricingConfigScreen extends ConsumerStatefulWidget {
  const AdminPricingConfigScreen({super.key});

  @override
  ConsumerState<AdminPricingConfigScreen> createState() => _AdminPricingConfigScreenState();
}

class _AdminPricingConfigScreenState extends ConsumerState<AdminPricingConfigScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Temporary local values during configuration edit
  double _baseRate = 1000.0;
  double _mistriWage = 800.0;
  double _beldarWage = 450.0;
  final Map<String, double> _metaValues = {};

  // Sandbox Simulator State Values (to see real-time calculation changes)
  double _sandboxVolume = 500.0; // sqft or points or count
  int _sandboxDays = 5;
  int _sandboxMistri = 2;
  int _sandboxBeldar = 1;
  bool _sandboxIncludeMaterial = true;
  bool _sandboxIsPremiumOrConcealed = true;

  final List<String> _services = [
    'electrical',
    'plumbing',
    'carpentry',
    'painting',
    'flooring',
    'civil'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _services.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Run post frame callback to load the initial tab values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActiveTabConfig();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadActiveTabConfig();
    }
  }

  void _loadActiveTabConfig() {
    final list = ref.read(pricingConfigProvider).value;
    if (list == null || list.isEmpty) return;

    final serviceType = _services[_tabController.index];
    final config = list.firstWhere(
      (c) => c.serviceType == serviceType,
      orElse: () => _getDefaultFallback(serviceType),
    );

    setState(() {
      _baseRate = config.baseRate;
      _mistriWage = config.mistriDailyWage;
      _beldarWage = config.beldarDailyWage;
      _metaValues.clear();
      config.additionalMeta.forEach((key, val) {
        if (val is num) {
          _metaValues[key] = val.toDouble();
        }
      });
    });
  }

  PricingConfig _getDefaultFallback(String serviceType) {
    if (serviceType == 'electrical') {
      return const PricingConfig(
        serviceType: 'electrical',
        baseRate: 800.0,
        mistriDailyWage: 750.0,
        beldarDailyWage: 450.0,
        additionalMeta: {
          'rough_in_material_rate': 120.0,
          'finish_material_rate': 70.0,
          'rough_in_labor_rate': 50.0,
          'finish_labor_rate': 30.0,
        },
      );
    } else if (serviceType == 'plumbing') {
      return const PricingConfig(
        serviceType: 'plumbing',
        baseRate: 900.0,
        mistriDailyWage: 800.0,
        beldarDailyWage: 450.0,
        additionalMeta: {
          'concealed_material_rate': 1500.0,
          'exposed_material_rate': 800.0,
          'concealed_labor_rate': 600.0,
          'exposed_labor_rate': 350.0,
        },
      );
    } else if (serviceType == 'carpentry') {
      return const PricingConfig(
        serviceType: 'carpentry',
        baseRate: 1500.0,
        mistriDailyWage: 850.0,
        beldarDailyWage: 450.0,
        additionalMeta: {
          'wardrobe_material_rate': 180.0,
          'other_material_rate': 250.0,
          'wardrobe_labor_rate': 60.0,
          'other_labor_rate': 80.0,
        },
      );
    } else if (serviceType == 'painting') {
      return const PricingConfig(
        serviceType: 'painting',
        baseRate: 1000.0,
        mistriDailyWage: 800.0,
        beldarDailyWage: 450.0,
        additionalMeta: {
          'fresh_premium_rate': 12.0,
          'fresh_standard_rate': 6.0,
          'repaint_premium_rate': 8.0,
          'repaint_standard_rate': 4.0,
          'labor_only_rate': 3.0,
        },
      );
    } else if (serviceType == 'flooring') {
      return const PricingConfig(
        serviceType: 'flooring',
        baseRate: 1200.0,
        mistriDailyWage: 900.0,
        beldarDailyWage: 450.0,
        additionalMeta: {
          'marble_material_rate': 4.5,
          'tiles_material_rate': 2.0,
          'labor_only_rate': 1.2,
          'mirror_polish_material_premium': 2.5,
          'mirror_polish_labor_premium': 1.5,
        },
      );
    } else {
      return const PricingConfig(
        serviceType: 'civil',
        baseRate: 1200.0,
        mistriDailyWage: 800.0,
        beldarDailyWage: 450.0,
        additionalMeta: {
          'material_rate_premium': 2.5,
          'material_rate_semi_premium': 1.5,
          'material_rate_standard': 1.0,
          'labor_factor': 0.45,
        },
      );
    }
  }

  double _calculateSimulatedSandboxPrice() {
    final serviceType = _services[_tabController.index];
    if (serviceType == 'electrical') {
      final roughInM = _metaValues['rough_in_material_rate'] ?? 120.0;
      final finishM = _metaValues['finish_material_rate'] ?? 70.0;
      final roughInL = _metaValues['rough_in_labor_rate'] ?? 50.0;
      final finishL = _metaValues['finish_labor_rate'] ?? 30.0;

      double pointCost = _sandboxIncludeMaterial
          ? (_sandboxIsPremiumOrConcealed ? (_sandboxVolume * roughInM) : (_sandboxVolume * finishM))
          : (_sandboxIsPremiumOrConcealed ? (_sandboxVolume * roughInL) : (_sandboxVolume * finishL));
      double laborCost = ((_sandboxMistri * _mistriWage) + (_sandboxBeldar * _beldarWage)) * _sandboxDays;
      return _baseRate + pointCost + laborCost;
    } else if (serviceType == 'plumbing') {
      final concealedM = _metaValues['concealed_material_rate'] ?? 1500.0;
      final exposedM = _metaValues['exposed_material_rate'] ?? 800.0;
      final concealedL = _metaValues['concealed_labor_rate'] ?? 600.0;
      final exposedL = _metaValues['exposed_labor_rate'] ?? 350.0;

      double plumbingCost = _sandboxVolume * (_sandboxIncludeMaterial
          ? (_sandboxIsPremiumOrConcealed ? concealedM : exposedM)
          : (_sandboxIsPremiumOrConcealed ? concealedL : exposedL));
      double laborCost = ((_sandboxMistri * _mistriWage) + (_sandboxBeldar * _beldarWage)) * _sandboxDays;
      return _baseRate + plumbingCost + laborCost;
    } else if (serviceType == 'carpentry') {
      final wardrobeM = _metaValues['wardrobe_material_rate'] ?? 180.0;
      final otherM = _metaValues['other_material_rate'] ?? 250.0;
      final wardrobeL = _metaValues['wardrobe_labor_rate'] ?? 60.0;
      final otherL = _metaValues['other_labor_rate'] ?? 80.0;

      double cabinetCost = _sandboxVolume * (_sandboxIncludeMaterial
          ? (_sandboxIsPremiumOrConcealed ? wardrobeM : otherM)
          : (_sandboxIsPremiumOrConcealed ? wardrobeL : otherL));
      double laborCost = ((_sandboxMistri * _mistriWage) + (_sandboxBeldar * _beldarWage)) * _sandboxDays;
      return _baseRate + cabinetCost + laborCost;
    } else if (serviceType == 'painting') {
      final freshPrem = _metaValues['fresh_premium_rate'] ?? 12.0;
      final freshStd = _metaValues['fresh_standard_rate'] ?? 6.0;
      final repaintPrem = _metaValues['repaint_premium_rate'] ?? 8.0;
      final repaintStd = _metaValues['repaint_standard_rate'] ?? 4.0;
      final laborOnly = _metaValues['labor_only_rate'] ?? 3.0;

      double materialRate = _sandboxIncludeMaterial
          ? (_sandboxIsPremiumOrConcealed
              ? (true ? freshPrem : freshStd)
              : (true ? repaintPrem : repaintStd))
          : laborOnly;
      double paintingCost = _sandboxVolume * materialRate;
      double laborCost = ((_sandboxMistri * _mistriWage) + (_sandboxBeldar * _beldarWage)) * _sandboxDays;
      return _baseRate + paintingCost + laborCost;
    } else if (serviceType == 'flooring') {
      final marbleM = _metaValues['marble_material_rate'] ?? 4.5;
      final tilesM = _metaValues['tiles_material_rate'] ?? 2.0;
      final laborOnly = _metaValues['labor_only_rate'] ?? 1.2;
      final mirrorPolishM = _metaValues['mirror_polish_material_premium'] ?? 2.5;
      final mirrorPolishL = _metaValues['mirror_polish_labor_premium'] ?? 1.5;

      double materialRate = _sandboxIncludeMaterial
          ? (_sandboxIsPremiumOrConcealed ? marbleM : tilesM)
          : laborOnly;
      double polishingPremium = _sandboxIsPremiumOrConcealed ? (_sandboxVolume * (_sandboxIncludeMaterial ? mirrorPolishM : mirrorPolishL)) : 0.0;
      double flooringCost = (_sandboxVolume * materialRate) + polishingPremium;
      double laborCost = ((_sandboxMistri * _mistriWage) + (_sandboxBeldar * _beldarWage)) * _sandboxDays;
      return _baseRate + flooringCost + laborCost;
    } else {
      final premM = _metaValues['material_rate_premium'] ?? 2.5;
      final semiPremM = _metaValues['material_rate_semi_premium'] ?? 1.5;
      final stdM = _metaValues['material_rate_standard'] ?? 1.0;
      final laborFact = _metaValues['labor_factor'] ?? 0.45;

      double materialFactor = _sandboxIsPremiumOrConcealed ? premM : stdM;
      double materialCost = _sandboxIncludeMaterial ? (_sandboxVolume * laborFact * materialFactor) : 0.0;
      double laborCost = ((_sandboxMistri * _mistriWage) + (_sandboxBeldar * _beldarWage)) * _sandboxDays;
      return _baseRate + materialCost + laborCost;
    }
  }

  Future<void> _publishActiveConfig() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final serviceType = _services[_tabController.index];
    final rates = {
      'base_rate': _baseRate,
      'mistri_daily_wage': _mistriWage,
      'beldar_daily_wage': _beldarWage,
      'additional_meta': _metaValues,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          SizedBox(width: 12),
          Text('Publishing pricing config to Supabase...'),
        ],
      )),
    );

    final success = await ref.read(pricingConfigProvider.notifier).updateRates(serviceType, rates);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kSuccess,
            content: Text('Pricing configurations updated and published successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: kDanger,
            content: Text('Failed to publish. Check console/RLS permissions.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pricingConfigProvider);

    ref.listen<AsyncValue<List<PricingConfig>>>(
      pricingConfigProvider,
      (previous, next) {
        if (next is AsyncData<List<PricingConfig>>) {
          _loadActiveTabConfig();
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Premium Dark Charcoal Canvas
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pricing Control Engine',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: kPrimary),
            onPressed: () => ref.invalidate(pricingConfigProvider),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: kPrimary,
          unselectedLabelColor: Colors.grey[500],
          indicatorColor: kPrimary,
          tabs: _services.map((name) => Tab(text: name.toUpperCase())).toList(),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
        data: (_) {
          final serviceType = _services[_tabController.index];
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final formWidget = _buildFormSection(serviceType);
              final simulatorWidget = _buildSandboxSimulator(serviceType);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: SingleChildScrollView(child: formWidget)),
                    const VerticalDivider(width: 1, color: Color(0xFF30363D)),
                    Expanded(flex: 2, child: SingleChildScrollView(child: simulatorWidget)),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      formWidget,
                      const Divider(height: 1, color: Color(0xFF30363D)),
                      simulatorWidget,
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildFormSection(String serviceType) {
    return Padding(
      padding: const EdgeInsets.all(spacingLg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: kPrimary),
                const SizedBox(width: 8),
                Text(
                  'Configure Rates for ${serviceType.toUpperCase()}',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: spacingLg),

            // Base platform fee
            _buildSliderRow(
              label: 'Platform Base Booking Fee',
              value: _baseRate,
              min: 100,
              max: 5000,
              divisions: 98, // Step of 50
              onChanged: (val) => setState(() => _baseRate = val),
            ),
            const Divider(color: Color(0xFF30363D), height: 32),

            // Labor config
            _buildSliderRow(
              label: 'Mistri (Daily Wage Rate)',
              value: _mistriWage,
              min: 300,
              max: 2500,
              divisions: 44, // Step of 50
              onChanged: (val) => setState(() => _mistriWage = val),
            ),
            const SizedBox(height: spacing),
            _buildSliderRow(
              label: 'Beldar/Helper (Daily Wage Rate)',
              value: _beldarWage,
              min: 200,
              max: 1500,
              divisions: 26, // Step of 50
              onChanged: (val) => setState(() => _beldarWage = val),
            ),
            const Divider(color: Color(0xFF30363D), height: 32),

            // Specialized Meta Parameters
            Text(
              'Specialized Service Sub-Rates',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70),
            ),
            const SizedBox(height: spacingSm),
            ..._metaValues.entries.map((entry) {
              final key = entry.key;
              final val = entry.value;
              String labelName = key.replaceAll('_', ' ').replaceAll('rate', '').trim();
              labelName = labelName[0].toUpperCase() + labelName.substring(1);

              final bool isFactor = key.contains('factor') || key.contains('coefficient') || key.contains('multiplier');
              final double sliderMin;
              final double sliderMax;
              final int sliderDivisions;
              final int decimalPlaces;

              if (isFactor || val < 1.0) {
                sliderMin = 0.0;
                sliderMax = 2.0;
                sliderDivisions = 100; // 0.02 step
                decimalPlaces = 2;
              } else if (val < 15.0) {
                sliderMin = 0.0;
                sliderMax = 50.0;
                sliderDivisions = 100; // 0.5 step
                decimalPlaces = 1;
              } else if (val < 100.0) {
                sliderMin = 10.0;
                sliderMax = 500.0;
                sliderDivisions = 98; // 5 step
                decimalPlaces = 0;
              } else {
                sliderMin = 50.0;
                sliderMax = 3000.0;
                sliderDivisions = 118; // 25 step
                decimalPlaces = 0;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: spacing),
                child: _buildSliderRow(
                  label: labelName,
                  value: val,
                  min: sliderMin,
                  max: sliderMax,
                  divisions: sliderDivisions,
                  isCurrency: !isFactor,
                  decimalPlaces: decimalPlaces,
                  onChanged: (newVal) {
                    setState(() {
                      _metaValues[key] = newVal;
                    });
                  },
                ),
              );
            }),

            const SizedBox(height: spacingLg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _publishActiveConfig,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: Text(
                      'Publish ${serviceType.toUpperCase()} Rates',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    bool isCurrency = true,
    int decimalPlaces = 0,
  }) {
    final formattedValue = isCurrency 
        ? '₹${value.toStringAsFixed(decimalPlaces)}' 
        : value.toStringAsFixed(decimalPlaces);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text(
              formattedValue,
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: kAccent, fontSize: 15),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: kPrimary,
          inactiveColor: const Color(0xFF30363D),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSandboxSimulator(String serviceType) {
    final double totalPrice = _calculateSimulatedSandboxPrice();

    return Container(
      margin: const EdgeInsets.all(spacingLg),
      padding: const EdgeInsets.all(spacingLg),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF30363D), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science_outlined, color: kAccent),
              const SizedBox(width: 8),
              Text(
                'Live Sandbox Simulator',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: spacing),
          const Text(
            'Preview how these rates calculate a mock client quote instantly:',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Divider(color: Color(0xFF30363D), height: 24),

          // Inputs for volume
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                serviceType == 'electrical' ? 'Points Count' : (serviceType == 'plumbing' ? 'Bathrooms' : 'Area (sqft)'),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
                    onPressed: () {
                      if (_sandboxVolume > 1) {
                        setState(() => _sandboxVolume -= (serviceType == 'plumbing' ? 1 : 50));
                      }
                    },
                  ),
                  Text(
                    _sandboxVolume.toStringAsFixed(0),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.grey, size: 20),
                    onPressed: () {
                      setState(() => _sandboxVolume += (serviceType == 'plumbing' ? 1 : 50));
                    },
                  ),
                ],
              ),
            ],
          ),

          // Inputs for days
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Work Duration (Days)', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 20),
                    onPressed: () {
                      if (_sandboxDays > 1) {
                        setState(() => _sandboxDays--);
                      }
                    },
                  ),
                  Text(
                    '$_sandboxDays',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.grey, size: 20),
                    onPressed: () {
                      setState(() => _sandboxDays++);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Material supplied by Ghulmil toggle
          SwitchListTile(
            title: const Text('Include Materials', style: TextStyle(color: Colors.white70, fontSize: 12)),
            value: _sandboxIncludeMaterial,
            activeColor: kPrimary,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _sandboxIncludeMaterial = val),
          ),

          SwitchListTile(
            title: Text(
              serviceType == 'electrical' ? 'Rough-in Phase' : (serviceType == 'plumbing' ? 'Concealed Piping' : 'Premium Grade'),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            value: _sandboxIsPremiumOrConcealed,
            activeColor: kPrimary,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _sandboxIsPremiumOrConcealed = val),
          ),
          const Divider(color: Color(0xFF30363D), height: 32),

          // Total Price Reveal Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(spacingLg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimary.withOpacity(0.12), kAccent.withOpacity(0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kPrimary.withOpacity(0.25), width: 1.0),
            ),
            child: Column(
              children: [
                const Text('SIMULATED TOTAL PRICE', style: TextStyle(color: kPrimary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                Text(
                  '₹${totalPrice.toStringAsFixed(0)}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: kPrimary.withOpacity(0.4), blurRadius: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Base Booking Fee:', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('₹${_baseRate.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Simulated Wages:', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text(
                      '₹${(((_sandboxMistri * _mistriWage) + (_sandboxBeldar * _beldarWage)) * _sandboxDays).toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
