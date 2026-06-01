import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/providers/booking_provider.dart';
import 'package:ghulmil_application/src/providers/service_provider.dart';
import 'package:ghulmil_application/src/models/service.dart';
import 'package:go_router/go_router.dart';

class RequirementIntakeScreen extends ConsumerStatefulWidget {
  final String serviceId;
  const RequirementIntakeScreen({super.key, required this.serviceId});

  @override
  ConsumerState<RequirementIntakeScreen> createState() => _RequirementIntakeScreenState();
}

class _RequirementIntakeScreenState extends ConsumerState<RequirementIntakeScreen> {
  int _currentStep = 0;

  // Form State Values (Civil)
  bool _includeMaterial = true;
  String _selectedMaterial = 'Standard';
  double _plotArea = 1000.0;
  int _mistriCount = 1;
  int _beldarCount = 2;
  int _workDays = 3;
  final _areaController = TextEditingController(text: '1000');

  // MEP: Electrical specific state
  bool _isRoughIn = true;
  int _pointCount = 10;
  final _pointController = TextEditingController(text: '10');

  // MEP: Plumbing specific state
  bool _isConcealed = true;
  int _bathroomCount = 1;

  // Finishing: Carpentry specific state
  bool _isWardrobe = true;
  double _cabinetHeight = 7.0;
  double _cabinetWidth = 4.0;
  final _heightController = TextEditingController(text: '7');
  final _widthController = TextEditingController(text: '4');

  // Finishing: Painting specific state
  bool _isFreshPaint = true;
  bool _isPremiumPaint = false;
  double _paintArea = 1000.0;
  final _paintAreaController = TextEditingController(text: '1000');

  // Finishing: Flooring specific state
  bool _isMarble = false;
  bool _isMirrorPolish = false;
  double _floorArea = 500.0;
  final _floorAreaController = TextEditingController(text: '500');

  // General fallback/generic Finishing
  String _finishType = 'Standard';
  double _finishArea = 500.0;
  final _finishAreaController = TextEditingController(text: '500');

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
      // Keep cleaning falling back to 'civil' for existing widget test compatibility
      return 'civil';
    } else {
      return 'civil';
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-start a new booking draft if none exists yet, so that reloading the page works perfectly
    Future.microtask(() {
      if (ref.read(bookingDraftProvider) == null) {
        ref.read(bookingDraftProvider.notifier).startDraft(widget.serviceId);
      }
    });

    _areaController.addListener(() {
      final value = double.tryParse(_areaController.text);
      if (value != null && value != _plotArea) {
        setState(() {
          _plotArea = value.clamp(100.0, 10000.0);
        });
      }
    });

    _pointController.addListener(() {
      final value = int.tryParse(_pointController.text);
      if (value != null && value != _pointCount) {
        setState(() {
          _pointCount = value.clamp(1, 200);
        });
      }
    });

    _finishAreaController.addListener(() {
      final value = double.tryParse(_finishAreaController.text);
      if (value != null && value != _finishArea) {
        setState(() {
          _finishArea = value.clamp(10.0, 5000.0);
        });
      }
    });

    _heightController.addListener(() {
      final value = double.tryParse(_heightController.text);
      if (value != null && value != _cabinetHeight) {
        setState(() {
          _cabinetHeight = value.clamp(1.0, 20.0);
        });
      }
    });

    _widthController.addListener(() {
      final value = double.tryParse(_widthController.text);
      if (value != null && value != _cabinetWidth) {
        setState(() {
          _cabinetWidth = value.clamp(1.0, 50.0);
        });
      }
    });

    _paintAreaController.addListener(() {
      final value = double.tryParse(_paintAreaController.text);
      if (value != null && value != _paintArea) {
        setState(() {
          _paintArea = value.clamp(10.0, 20000.0);
        });
      }
    });

    _floorAreaController.addListener(() {
      final value = double.tryParse(_floorAreaController.text);
      if (value != null && value != _floorArea) {
        setState(() {
          _floorArea = value.clamp(10.0, 20000.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _areaController.dispose();
    _pointController.dispose();
    _finishAreaController.dispose();
    _heightController.dispose();
    _widthController.dispose();
    _paintAreaController.dispose();
    _floorAreaController.dispose();
    super.dispose();
  }

  // Live Pricing Calculation Engine
  double _calculateTotalPrice(String serviceType) {
    if (serviceType == 'electrical') {
      const double baseRate = 800.0;
      double pointCost = _includeMaterial
          ? (_isRoughIn ? (_pointCount * 120.0) : (_pointCount * 70.0))
          : (_isRoughIn ? (_pointCount * 50.0) : (_pointCount * 30.0));
      const double mepDailyWage = 750.0;
      const double helperDailyWage = 450.0;
      double laborCost = ((_mistriCount * mepDailyWage) + (_beldarCount * helperDailyWage)) * _workDays;
      return baseRate + pointCost + laborCost;
    } else if (serviceType == 'plumbing') {
      const double baseRate = 900.0;
      double plumbingCost = _bathroomCount * (_includeMaterial
          ? (_isConcealed ? 1500.0 : 800.0)
          : (_isConcealed ? 600.0 : 350.0));
      const double plumberDailyWage = 800.0;
      const double helperDailyWage = 450.0;
      double laborCost = ((_mistriCount * plumberDailyWage) + (_beldarCount * helperDailyWage)) * _workDays;
      return baseRate + plumbingCost + laborCost;
    } else if (serviceType == 'carpentry') {
      const double baseRate = 1500.0;
      double cabinetArea = _cabinetHeight * _cabinetWidth;
      double cabinetCost = cabinetArea * (_includeMaterial
          ? (_isWardrobe ? 180.0 : 250.0)
          : (_isWardrobe ? 60.0 : 80.0));
      const double carpenterDailyWage = 850.0;
      const double helperDailyWage = 450.0;
      double laborCost = ((_mistriCount * carpenterDailyWage) + (_beldarCount * helperDailyWage)) * _workDays;
      return baseRate + cabinetCost + laborCost;
    } else if (serviceType == 'painting') {
      const double baseRate = 1000.0;
      double materialRate = _includeMaterial
          ? (_isFreshPaint
              ? (_isPremiumPaint ? 12.0 : 6.0)
              : (_isPremiumPaint ? 8.0 : 4.0))
          : 3.0;
      double paintingCost = _paintArea * materialRate;
      const double painterDailyWage = 800.0;
      const double helperDailyWage = 450.0;
      double laborCost = ((_mistriCount * painterDailyWage) + (_beldarCount * helperDailyWage)) * _workDays;
      return baseRate + paintingCost + laborCost;
    } else if (serviceType == 'flooring') {
      const double baseRate = 1200.0;
      double materialRate = _includeMaterial
          ? (_isMarble ? 4.5 : 2.0)
          : 1.2;
      double polishingPremium = _isMirrorPolish ? (_floorArea * (_includeMaterial ? 2.5 : 1.5)) : 0.0;
      double flooringCost = (_floorArea * materialRate) + polishingPremium;
      const double flooringDailyWage = 900.0;
      const double helperDailyWage = 450.0;
      double laborCost = ((_mistriCount * flooringDailyWage) + (_beldarCount * helperDailyWage)) * _workDays;
      return baseRate + flooringCost + laborCost;
    } else {
      const double baseRate = 1200.0; // Base platform & tooling rate
      double materialFactor = _selectedMaterial == 'Premium' ? 2.5 : (_selectedMaterial == 'Semi-Premium' ? 1.5 : 1.0);
      double materialCost = _includeMaterial ? (_plotArea * 0.45 * materialFactor) : 0.0;
      const double mistriDailyWage = 800.0;
      const double beldarDailyWage = 450.0;
      double laborCost = ((_mistriCount * mistriDailyWage) + (_beldarCount * beldarDailyWage)) * _workDays;
      return baseRate + materialCost + laborCost;
    }
  }

  void _submitRequirements(String defaultPackageId, String serviceType) {
    final Map<String, dynamic> customRequirements = {
      'service_type': serviceType,
      'materials_supplied_by_ghulmil': _includeMaterial,
      'material_quality': !_includeMaterial
          ? 'None (Customer Inventory)'
          : (serviceType == 'electrical'
              ? (_isRoughIn ? 'Rough Conduit & Pipes' : 'Final Terminals')
              : (serviceType == 'plumbing'
                  ? (_isConcealed ? 'Concealed Piping' : 'Open Piping')
                  : (serviceType == 'carpentry'
                      ? (_isWardrobe ? 'Laminate Wardrobe' : 'Modular Kitchen')
                      : (serviceType == 'painting'
                          ? (_isFreshPaint ? 'Fresh Paint (${_isPremiumPaint ? "Premium" : "Standard"})' : 'Repaint')
                          : (serviceType == 'flooring'
                              ? '${_isMarble ? "Marble" : "Tile"} (${_isMirrorPolish ? "Mirror Polish" : "Standard"})'
                              : _selectedMaterial))))),
      'plot_area_sqft': serviceType == 'electrical'
          ? _pointCount.toDouble()
          : (serviceType == 'plumbing'
              ? _bathroomCount.toDouble()
              : (serviceType == 'carpentry'
                  ? (_cabinetHeight * _cabinetWidth)
                  : (serviceType == 'painting'
                      ? _paintArea
                      : (serviceType == 'flooring' ? _floorArea : _plotArea)))),
      'work_days': _workDays,
      'raj_mistri_count': _mistriCount,
      'beldar_count': _beldarCount,
      'computed_price': _calculateTotalPrice(serviceType),
    };

    final bookingNotifier = ref.read(bookingDraftProvider.notifier);
    
    // Save serialized JSON directly inside the backward-compatible notes field
    bookingNotifier.setPackage(defaultPackageId);
    bookingNotifier.setNotes(jsonEncode(customRequirements));

    // Navigate to date & time scheduling
    context.pushNamed('schedule', pathParameters: {'serviceId': widget.serviceId});
  }

  @override
  Widget build(BuildContext context) {
    final serviceAsync = ref.watch(serviceProvider(widget.serviceId));

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _currentStep--;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configure Requirements'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep--;
                });
              } else {
                context.pop();
              }
            },
          ),
        ),
      body: serviceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (service) {
          final defaultPackageId = service.packages.isNotEmpty ? service.packages.first.id : 'dummy_package';
          final serviceType = _getServiceType(service);

          return Column(
            children: [
              // Step Progress Bar
              _buildStepProgress(serviceType),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Conversational Step Content
                      if (_currentStep == 0) ...[
                        if (serviceType == 'electrical') _buildMepStageStep()
                        else if (serviceType == 'plumbing') _buildPlumbingStageStep()
                        else if (serviceType == 'carpentry') _buildCarpentryTypeStep()
                        else if (serviceType == 'painting') _buildPaintingTypeStep()
                        else if (serviceType == 'flooring') _buildFlooringMaterialStep()
                        else _buildMaterialStep()
                      ] else if (_currentStep == 1) ...[
                        if (serviceType == 'electrical') _buildMepPointsStep()
                        else if (serviceType == 'plumbing') _buildPlumbingBathroomsStep()
                        else if (serviceType == 'carpentry') _buildCarpentryDimensionsStep()
                        else if (serviceType == 'painting') _buildPaintingAreaStep()
                        else if (serviceType == 'flooring') _buildFlooringAreaStep()
                        else _buildDimensionsStep()
                      ] else ...[
                        _buildLaborStep(serviceType)
                      ],

                      const SizedBox(height: spacingLg),

                      // Smart Live Estimate Card
                      _buildLiveEstimateCard(serviceType),
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons
              _buildNavigationButtons(defaultPackageId, serviceType),
            ],
          );
        },
      ),
    ),
  );
}

  Widget _buildMaterialSupplyHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material Kaun Laayega? (Material Supply)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: kPrimary),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Choose whether you want Ghulmil to supply structural/finishing materials or you will provide your own.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacing),

        // Yes/No Choice Cards
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: _includeMaterial ? 2 : 0,
                color: _includeMaterial ? kPrimary.withOpacity(0.05) : kSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: _includeMaterial ? const BorderSide(color: kPrimary, width: 1.5) : BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                child: InkWell(
                  onTap: () => setState(() => _includeMaterial = true),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_shipping_outlined, color: _includeMaterial ? kPrimary : kMuted, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Ghulmil Supplies',
                          style: TextStyle(
                            fontWeight: _includeMaterial ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                            color: _includeMaterial ? kPrimary : kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: spacingSm),
            Expanded(
              child: Card(
                elevation: !_includeMaterial ? 2 : 0,
                color: !_includeMaterial ? kPrimary.withOpacity(0.05) : kSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: !_includeMaterial ? const BorderSide(color: kPrimary, width: 1.5) : BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                child: InkWell(
                  onTap: () => setState(() => _includeMaterial = false),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, color: !_includeMaterial ? kPrimary : kMuted, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Only Labor',
                          style: TextStyle(
                            fontWeight: !_includeMaterial ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                            color: !_includeMaterial ? kPrimary : kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: spacing),
        const Divider(),
        const SizedBox(height: spacing),
      ],
    );
  }

  Widget _buildCustomerMaterialNotice(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: spacing),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kPrimary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: kPrimary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$message Only professional labor work and tooling are included in the Ghulmil estimate.',
              style: const TextStyle(fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgress(String serviceType) {
    final step1Title = serviceType == 'mep'
        ? 'Kaam ka Stage'
        : (serviceType == 'finishing' ? 'Kaam ki Quality' : 'Material');

    final step2Title = serviceType == 'mep'
        ? 'Points (Outlets)'
        : (serviceType == 'finishing' ? 'Kaam ka Area' : 'Daimensan (Size)');

    final step3Title = serviceType == 'mep'
        ? 'Karigar'
        : (serviceType == 'finishing' ? 'Karigar' : 'Karigar (Labour)');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: spacingSm, horizontal: spacing),
      color: Colors.white,
      child: Row(
        children: [
          _buildStepNode(0, step1Title),
          _buildStepConnector(0),
          _buildStepNode(1, step2Title),
          _buildStepConnector(1),
          _buildStepNode(2, step3Title),
        ],
      ),
    );
  }

  Widget _buildStepNode(int index, String title) {
    final isActive = _currentStep == index;
    final isDone = _currentStep > index;

    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isDone ? kSuccess : (isActive ? kPrimary : kSurface),
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : kMuted,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? kPrimary : kMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int afterIndex) {
    final isDone = _currentStep > afterIndex;
    return Container(
      width: 24,
      height: 2,
      color: isDone ? kSuccess : kSurface,
    );
  }

  Widget _buildMaterialStep() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material Kaun Laayega? (Material Supply)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Choose whether you want Ghulmil to supply structural materials or you will provide your own.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacing),

        // Yes/No Choice Cards
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: _includeMaterial ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: _includeMaterial ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => setState(() => _includeMaterial = true),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Icon(Icons.local_shipping_outlined, color: _includeMaterial ? kPrimary : kMuted, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Ghulmil se Chahiye',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Materials + Labor combo',
                          style: TextStyle(color: kMuted, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: Card(
                elevation: !_includeMaterial ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: !_includeMaterial ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => setState(() => _includeMaterial = false),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, color: !_includeMaterial ? kPrimary : kMuted, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Mere paas taiyar hai',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Only Labor (₹0 Material)',
                          style: TextStyle(color: kMuted, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: spacingLg),

        if (_includeMaterial) ...[
          Text(
            'Kaam ki Quality (Material Preference)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: spacingXs),
          Text(
            'Select the quality standard for brickwork and plastering.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kMuted),
          ),
          const SizedBox(height: spacing),
          _buildMaterialCard(
            'Standard',
            'Laal Eent (Standard red bricks), Ultratech concrete, locally washed fine sand.',
            '₹',
            Icons.gpp_good_outlined,
          ),
          const SizedBox(height: spacing),
          _buildMaterialCard(
            'Semi-Premium',
            'High strength machine bricks, premium ACC gold cement, double-washed river sand.',
            '₹₹',
            Icons.workspace_premium_outlined,
          ),
          const SizedBox(height: spacing),
          _buildMaterialCard(
            'Premium',
            'Premium fly-ash bricks, waterproof plastering chemicals, structural grade Birla cement.',
            '₹₹₹',
            Icons.diamond_outlined,
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.secondary, size: 24),
                const SizedBox(width: spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Labor-Only Service Selected',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'You will only pay for daily workforce wages (₹800/day Raj Mistri, ₹450/day Beldar) and platform booking fees. Please ensure bricks (eent), cement, sand (masala), and scaffolding are fully ready on-site before the team arrives.',
                        style: TextStyle(fontSize: 11, height: 1.4, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMaterialCard(String label, String desc, String costIndicator, IconData icon) {
    final isSelected = _selectedMaterial == label;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedMaterial = label),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(spacing),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: isSelected ? kPrimary : kMuted, size: 28),
              const SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        Text(costIndicator, style: const TextStyle(color: kAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: spacingXs),
                    Text(desc, style: const TextStyle(color: kMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plot ka Daimensan (Area & Timeline)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Specify the total carpet area requiring brickwork or concrete.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacingLg),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Area (sq. ft.)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.square_foot),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            const Expanded(
              flex: 1,
              child: Text('Sq. Ft.', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: spacing),

        Slider(
          value: _plotArea,
          min: 100.0,
          max: 10000.0,
          divisions: 99,
          activeColor: kPrimary,
          label: '${_plotArea.toStringAsFixed(0)} sqft',
          onChanged: (val) {
            setState(() {
              _plotArea = val;
              _areaController.text = val.toStringAsFixed(0);
            });
          },
        ),
        const SizedBox(height: spacingLg),

        Text(
          'Kitne din ka kaam hai? (Work Timeline)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Estimated work duration:'),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: kPrimary),
                  onPressed: _workDays > 1 ? () => setState(() => _workDays--) : null,
                ),
                Text('$_workDays Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: kPrimary),
                  onPressed: _workDays < 30 ? () => setState(() => _workDays++) : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLaborStep(String serviceType) {
    final skilledTitle = serviceType == 'mep'
        ? 'Electrician / Plumber (Skilled Tech)'
        : (serviceType == 'finishing'
            ? 'Skilled Karigar (Badhai / Paint Mistri)'
            : 'Raj Mistri (Skilled Masons)');

    final skilledSubtitle = serviceType == 'mep'
        ? 'Responsible for cutting channels, drawing wires, or precise sanitary/pipe joins.'
        : (serviceType == 'finishing'
            ? 'Responsible for high-accuracy wood cutouts, sanding, putty leveling, & textures.'
            : 'Responsible for brick alignment, plastering, and plumbing bob (sahul) checks.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          serviceType == 'mep'
              ? 'Bijli-Sanitary Karigar (Workforce)'
              : (serviceType == 'finishing'
                  ? 'Mistri aur Beldar (Site Workforce)'
                  : 'Karigar aur Beldar (Site Workforce)'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Define the labor combination needed for this work.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacing),

        _buildLaborCounter(
          skilledTitle,
          skilledSubtitle,
          _mistriCount,
          (val) => setState(() => _mistriCount = val),
        ),
        const SizedBox(height: spacing),
        _buildLaborCounter(
          'Beldar / Helper (Unskilled Support)',
          'Responsible for mixing cement mortar (masala), moving materials, and curing/cleanup.',
          _beldarCount,
          (val) => setState(() => _beldarCount = val),
        ),
      ],
    );
  }

  Widget _buildLaborCounter(String title, String subtitle, int count, Function(int) onChange) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: kPrimary),
                      onPressed: count > 0 ? () => onChange(count - 1) : null,
                    ),
                    Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: kPrimary),
                      onPressed: count < 10 ? () => onChange(count + 1) : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: spacingXs),
            Text(subtitle, style: const TextStyle(color: kMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveEstimateCard(String serviceType) {
    final totalPrice = _calculateTotalPrice(serviceType);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kPrimary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_outlined, color: kPrimary),
                const SizedBox(width: spacingSm),
                Text(
                  'Smart Estimate (Live Quote)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: spacingLg),
            if (serviceType == 'mep') ...[
              _buildPriceRow(
                '$_pointCount Points · ${_isRoughIn ? "Jhirri/Conduit" : "Fitting"} Material',
                '₹${(_isRoughIn ? (_pointCount * 120.0) : (_pointCount * 70.0)).toStringAsFixed(0)}',
              ),
              _buildPriceRow('Workforce Wage ($_mistriCount Karigar + $_beldarCount Helper)', '₹${(((_mistriCount * 750) + (_beldarCount * 450)) * _workDays).toStringAsFixed(0)}'),
            ] else if (serviceType == 'finishing') ...[
              _buildPriceRow(
                '$_finishType Material & Finishing',
                '₹${(_finishArea * (_finishType == 'Premium' ? 6.5 : (_finishType == 'Semi-Premium' ? 3.5 : 2.0))).toStringAsFixed(0)}',
              ),
              _buildPriceRow('Workforce Wage ($_mistriCount Karigar + $_beldarCount Helper)', '₹${(((_mistriCount * 850) + (_beldarCount * 450)) * _workDays).toStringAsFixed(0)}'),
            ] else ...[
              _buildPriceRow(
                _includeMaterial
                    ? '$_selectedMaterial Material Cost'
                    : 'Material Cost (Procured by Customer)',
                _includeMaterial
                    ? '₹${(_plotArea * 0.45 * (_selectedMaterial == 'Premium' ? 2.5 : (_selectedMaterial == 'Semi-Premium' ? 1.5 : 1.0))).toStringAsFixed(0)}'
                    : '₹0',
              ),
              _buildPriceRow('Workforce Wage ($_mistriCount Mistri + $_beldarCount Beldar)', '₹${(((_mistriCount * 800) + (_beldarCount * 450)) * _workDays).toStringAsFixed(0)}'),
            ],
            const Divider(height: spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimated Total (INR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  '₹${totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: kPrimary),
                ),
              ],
            ),
            const SizedBox(height: spacingSm),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 12, color: kMuted),
                const SizedBox(width: spacingXs),
                Expanded(
                  child: Text(
                    serviceType == 'mep'
                        ? 'Note: Wages calculated as per standard electrical & plumbing daily rates in India (₹750/day Plumber/Electrician).'
                        : (serviceType == 'finishing'
                            ? 'Note: Wages calculated as per standard carpentry & painting daily rates in India (₹850/day skilled Karigar).'
                            : 'Note: Wages calculated as per standard daily rates in India (₹800/day Raj Mistri, ₹450/day Beldar).'),
                    style: const TextStyle(color: kMuted, fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kMuted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(String defaultPackageId, String serviceType) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(spacing),
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: const Text('Back'),
              ),
              const SizedBox(width: spacing),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < 2) {
                    setState(() => _currentStep++);
                  } else {
                    _submitRequirements(defaultPackageId, serviceType);
                  }
                },
                child: Text(_currentStep < 2 ? 'Continue' : 'Verify & Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMepStageStep() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMaterialSupplyHeader(),
        Text(
          'Kaam ka Stage (Work Phase)',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Select the stage of electrical work required.',
          style: theme.textTheme.bodyMedium?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacing),

        Row(
          children: [
            Expanded(
              child: Card(
                elevation: _isRoughIn ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: _isRoughIn ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => setState(() => _isRoughIn = true),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Icon(Icons.plumbing_outlined, color: _isRoughIn ? kPrimary : kMuted, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Jhirri aur Conduit',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Wall cutting & piping before plaster',
                          style: TextStyle(color: kMuted, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: Card(
                elevation: !_isRoughIn ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: !_isRoughIn ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => setState(() => _isRoughIn = false),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Icon(Icons.power_outlined, color: !_isRoughIn ? kPrimary : kMuted, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Fitting aur Connection',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Install switches, lights, taps, & boards',
                          style: TextStyle(color: kMuted, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!_includeMaterial)
          _buildCustomerMaterialNotice('Using customer supplied electrical conduit pipes, wires, sockets, and boards.')
        else ...[
          const SizedBox(height: spacingLg),
          Container(
            padding: const EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.secondary, size: 24),
                const SizedBox(width: spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Materials Included',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Conduit Pipes, Sockets, Junction Boxes, standard wires and professional tools are supplied entirely by Ghulmil.',
                        style: TextStyle(fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMepPointsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Point ya Outlet ka Count (Total Outlets)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Specify the number of electrical board points or plumbing fixtures/taps to configure.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacingLg),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _pointController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Points / Fixtures Count',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pin),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            const Expanded(
              flex: 1,
              child: Text('Points', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: spacing),

        Slider(
          value: _pointCount.toDouble(),
          min: 1.0,
          max: 200.0,
          divisions: 199,
          activeColor: kPrimary,
          label: '$_pointCount Points',
          onChanged: (val) {
            setState(() {
              _pointCount = val.toInt();
              _pointController.text = val.toStringAsFixed(0);
            });
          },
        ),
        const SizedBox(height: spacingLg),

        Text(
          'Kitne din ka kaam hai? (Work Timeline)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Estimated work duration:'),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: kPrimary),
                  onPressed: _workDays > 1 ? () => setState(() => _workDays--) : null,
                ),
                Text('$_workDays Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: kPrimary),
                  onPressed: _workDays < 30 ? () => setState(() => _workDays++) : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildPlumbingStageStep() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMaterialSupplyHeader(),
        Text(
          'Piping Alignment (Sanitary Fitting)',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Choose the alignment design for the plumbing system.',
          style: theme.textTheme.bodyMedium?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacing),

        Row(
          children: [
            Expanded(
              child: Card(
                elevation: _isConcealed ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: _isConcealed ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => setState(() => _isConcealed = true),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Icon(Icons.visibility_off_outlined, color: _isConcealed ? kPrimary : kMuted, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Concealed Piping',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Deewar ke andar pipe fitment',
                          style: TextStyle(color: kMuted, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: Card(
                elevation: !_isConcealed ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: !_isConcealed ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => setState(() => _isConcealed = false),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Icon(Icons.visibility_outlined, color: !_isConcealed ? kPrimary : kMuted, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Open Piping',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Exposed easy-maintenance pipes',
                          style: TextStyle(color: kMuted, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        if (!_includeMaterial)
          _buildCustomerMaterialNotice('Using customer supplied plumbing CPVC/UPVC pipes, tees, bends, and sanitary fittings.')
        else ...[
          const SizedBox(height: spacingLg),
          Container(
            padding: const EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.secondary, size: 24),
                const SizedBox(width: spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Materials Included',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'High-quality CPVC/UPVC pipes, solvent weld, clips, brackets, and professional tools are supplied entirely by Ghulmil.',
                        style: TextStyle(fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlumbingBathroomsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Bathrooms / Kitchen Outlets',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Specify the count of independent wet areas (e.g. bathroom, modular kitchen connections) requiring pipe layouts.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacingLg),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Wet Areas (Bathrooms/Kitchens):', style: TextStyle(fontWeight: FontWeight.w500)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: kPrimary),
                  onPressed: _bathroomCount > 1 ? () => setState(() => _bathroomCount--) : null,
                ),
                Text('$_bathroomCount Areas', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: kPrimary),
                  onPressed: _bathroomCount < 10 ? () => setState(() => _bathroomCount++) : null,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: spacingLg),

        Text(
          'Kitne din ka kaam hai? (Work Timeline)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Estimated work duration:'),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: kPrimary),
                  onPressed: _workDays > 1 ? () => setState(() => _workDays--) : null,
                ),
                Text('$_workDays Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: kPrimary),
                  onPressed: _workDays < 30 ? () => setState(() => _workDays++) : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarpentryTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMaterialSupplyHeader(),
        Text(
          'Kaam ka Type (Carpentry Type)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Select the type of woodwork or modular cabinetry required.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacing),

        Row(
          children: [
            Expanded(
              child: Card(
                elevation: _isWardrobe ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: _isWardrobe ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => setState(() => _isWardrobe = true),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Icon(Icons.door_sliding_outlined, color: _isWardrobe ? kPrimary : kMuted, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Laminate Wardrobe',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Wardrobes & Almirahs with Sunmica',
                          style: TextStyle(color: kMuted, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: Card(
                elevation: !_isWardrobe ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: !_isWardrobe ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => setState(() => _isWardrobe = false),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Icon(Icons.kitchen_outlined, color: !_isWardrobe ? kPrimary : kMuted, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Modular Kitchen',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Cabinets, baskets, & U/L-shaped structures',
                          style: TextStyle(color: kMuted, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        if (!_includeMaterial)
          _buildCustomerMaterialNotice('Using customer supplied plywood, laminates/Sunmica, hinges, handles, and glue.')
        else ...[
          const SizedBox(height: spacingLg),
          Container(
            padding: const EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary, size: 24),
                const SizedBox(width: spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Materials Included',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Premium grade water-resistant plywood, standard laminates, soft-close hinges, baskets, handles, and adhesive are included combo.',
                        style: TextStyle(fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCarpentryDimensionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Almirah / Cabinet Dimensions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Enter the face dimensions of the almirah or kitchen cabinets in feet to calculate total square footage.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacingLg),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Height (in Feet)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.height),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: TextFormField(
                controller: _widthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Width / Length (in Feet)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.width_full_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: spacingLg),

        Container(
          padding: const EdgeInsets.all(spacing),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Computed Cabinetry Area:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '${(_cabinetHeight * _cabinetWidth).toStringAsFixed(1)} Sq. Ft.',
                style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: spacingLg),

        Text(
          'Kitne din ka kaam hai? (Work Timeline)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Estimated work duration:'),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: kPrimary),
                  onPressed: _workDays > 1 ? () => setState(() => _workDays--) : null,
                ),
                Text('$_workDays Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: kPrimary),
                  onPressed: _workDays < 30 ? () => setState(() => _workDays++) : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaintingTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMaterialSupplyHeader(),
        Text(
          'Rangai ka Level (Deewar Stage)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Specify whether you need a fresh double-coat painting setup or standard repainting.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacing),

        Row(
          children: [
            Expanded(
              child: Card(
                elevation: _isFreshPaint ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: _isFreshPaint ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => setState(() => _isFreshPaint = true),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Icon(Icons.layers_outlined, color: _isFreshPaint ? kPrimary : kMuted, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Nayi Deewar (Fresh Paint)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Putty, sanding, primer, & double coat',
                          style: TextStyle(color: kMuted, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: Card(
                elevation: !_isFreshPaint ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: !_isFreshPaint ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => setState(() => _isFreshPaint = false),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Icon(Icons.format_paint_outlined, color: !_isFreshPaint ? kPrimary : kMuted, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Repaint / Touchup',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Quick touchup on existing clean walls',
                          style: TextStyle(color: kMuted, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        if (_includeMaterial) ...[
          const SizedBox(height: spacingLg),
          Text(
            'Paint ki Quality (Paint Grade)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: spacingSm),
          Wrap(
            spacing: spacingSm,
            runSpacing: spacingSm,
            children: [
              ChoiceChip(
                label: const Text('Standard Emulsion'),
                selected: !_isPremiumPaint,
                onSelected: (selected) {
                  if (selected) setState(() => _isPremiumPaint = false);
                },
              ),
              ChoiceChip(
                label: const Text('Premium / Textures (Royal Play)'),
                selected: _isPremiumPaint,
                onSelected: (selected) {
                  if (selected) setState(() => _isPremiumPaint = true);
                },
              ),
            ],
          ),
        ] else
          _buildCustomerMaterialNotice('Using customer supplied paint, wall putty, and primer.'),
      ],
    );
  }

  Widget _buildPaintingAreaStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Painting Wall Area (sq. ft.)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Specify the total wall or ceiling area in sq. ft. to be colored.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacingLg),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _paintAreaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Wall Area (sq. ft.)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.square_foot),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            const Expanded(
              flex: 1,
              child: Text('Sq. Ft.', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: spacing),

        Slider(
          value: _paintArea,
          min: 10.0,
          max: 20000.0,
          divisions: 199,
          activeColor: kPrimary,
          label: '${_paintArea.toStringAsFixed(0)} sqft',
          onChanged: (val) {
            setState(() {
              _paintArea = val;
              _paintAreaController.text = val.toStringAsFixed(0);
            });
          },
        ),
        const SizedBox(height: spacingLg),

        Text(
          'Kitne din ka kaam hai? (Work Timeline)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Estimated work duration:'),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: kPrimary),
                  onPressed: _workDays > 1 ? () => setState(() => _workDays--) : null,
                ),
                Text('$_workDays Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: kPrimary),
                  onPressed: _workDays < 30 ? () => setState(() => _workDays++) : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlooringMaterialStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMaterialSupplyHeader(),
        Text(
          'Flooring Material Choice',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Select the flooring material required for installation.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacing),

        Row(
          children: [
            Expanded(
              child: Card(
                elevation: !_isMarble ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: !_isMarble ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => setState(() => _isMarble = false),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Icon(Icons.grid_on_outlined, color: !_isMarble ? kPrimary : kMuted, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Ceramic / Tiles',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Standard tiles fitment',
                          style: TextStyle(color: kMuted, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: Card(
                elevation: _isMarble ? 3 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: _isMarble ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => setState(() => _isMarble = true),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Icon(Icons.layers_outlined, color: _isMarble ? kPrimary : kMuted, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Marble / Granite',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Premium stone with Ghisai',
                          style: TextStyle(color: kMuted, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        if (!_includeMaterial)
          _buildCustomerMaterialNotice('Using customer supplied ceramic/vitrified tiles, marble slabs, granite, and adhesive/cement.')
        else ...[
          if (_isMarble) ...[
            const SizedBox(height: spacingLg),
            Text(
              'Stone Polish Preference (Ghisai)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: spacingSm),
            CheckboxListTile(
              title: const Text('Italian Diamond Ghisai (Mirror Polish)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text('Multi-stage diamond stone polishing for high gloss mirror finishes', style: TextStyle(fontSize: 11)),
              value: _isMirrorPolish,
              activeColor: kPrimary,
              onChanged: (val) {
                setState(() {
                  _isMirrorPolish = val ?? false;
                });
              },
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildFlooringAreaStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flooring Floor Area (sq. ft.)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Text(
          'Specify the total floor layout area in sq. ft.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kMuted),
        ),
        const SizedBox(height: spacingLg),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _floorAreaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Floor Area (sq. ft.)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.square_foot),
                ),
              ),
            ),
            const SizedBox(width: spacing),
            const Expanded(
              flex: 1,
              child: Text('Sq. Ft.', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: spacing),

        Slider(
          value: _floorArea,
          min: 10.0,
          max: 20000.0,
          divisions: 199,
          activeColor: kPrimary,
          label: '${_floorArea.toStringAsFixed(0)} sqft',
          onChanged: (val) {
            setState(() {
              _floorArea = val;
              _floorAreaController.text = val.toStringAsFixed(0);
            });
          },
        ),
        const SizedBox(height: spacingLg),

        Text(
          'Kitne din ka kaam hai? (Work Timeline)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: spacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Estimated work duration:'),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: kPrimary),
                  onPressed: _workDays > 1 ? () => setState(() => _workDays--) : null,
                ),
                Text('$_workDays Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: kPrimary),
                  onPressed: _workDays < 30 ? () => setState(() => _workDays++) : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
