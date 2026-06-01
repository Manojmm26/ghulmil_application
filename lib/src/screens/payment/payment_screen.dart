import 'dart:convert';
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

    try {
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
    } catch (error, stack) {
      print('DEBUG: _confirmAndPay caught error: $error\n$stack');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingDraft = ref.watch(bookingDraftProvider);
    print('DEBUG: payment_screen build - draft=$bookingDraft, notes=${bookingDraft?.notes}, packageId=${bookingDraft?.packageId}');

    // Try parsing custom requirements from draft notes
    Map<String, dynamic>? customReqs;
    if (bookingDraft != null && bookingDraft.notes != null) {
      try {
        customReqs = jsonDecode(bookingDraft.notes!);
      } catch (_) {}
    }

    final bool isCustomRequirement = customReqs != null && (
      customReqs['service_type'] == 'civil' ||
      customReqs['service_type'] == 'civil_masonry' ||
      customReqs['service_type'] == 'electrical' ||
      customReqs['service_type'] == 'plumbing' ||
      customReqs['service_type'] == 'carpentry' ||
      customReqs['service_type'] == 'painting' ||
      customReqs['service_type'] == 'flooring'
    );
    
    String serviceTitle = 'Standard Clean';
    if (isCustomRequirement) {
      final type = customReqs!['service_type'];
      if (type == 'electrical') {
        serviceTitle = 'MEP: Electrical Work (Bijli Fitting)';
      } else if (type == 'plumbing') {
        serviceTitle = 'MEP: Plumbing Work (Nal aur Sanitary)';
      } else if (type == 'carpentry') {
        serviceTitle = 'Interior: Carpentry Woodwork (Badhai Kaam)';
      } else if (type == 'painting') {
        serviceTitle = 'Interior: Wall Painting (Rangai Putty)';
      } else if (type == 'flooring') {
        serviceTitle = 'Interior: Tiles & Marble Flooring (Ghisai)';
      } else {
        serviceTitle = 'Civil Masonry & Concrete (Lenter/Chunai)';
      }
    }
        
    final double basePrice = isCustomRequirement 
        ? (customReqs!['computed_price'] as num).toDouble() 
        : 49.99;
        
    final double taxPrice = isCustomRequirement 
        ? basePrice * 0.05 
        : 5.00;
        
    final double totalPrice = basePrice + taxPrice;

    final String currencySymbol = isCustomRequirement ? '₹' : '\$';

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(serviceTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (isCustomRequirement) ...[
                                const SizedBox(height: 4),
                                Builder(
                                  builder: (context) {
                                    final serviceType = customReqs!['service_type'];
                                    final workDays = customReqs['work_days'];
                                    final mistri = customReqs['raj_mistri_count'];
                                    final beldar = customReqs['beldar_count'];
                                    final materialsSuppliedByGhulmil = customReqs['materials_supplied_by_ghulmil'] as bool? ?? true;
                                    final materialText = materialsSuppliedByGhulmil ? 'Ghulmil Material' : 'Customer Material (Labor Only)';

                                    if (serviceType == 'electrical') {
                                      final points = customReqs['plot_area_sqft'] as num;
                                      final stageText = customReqs['material_quality'];
                                      return Text(
                                        '${points.toStringAsFixed(0)} Points · Stage: $stageText · $materialText\n$workDays Days · $mistri Electrician + $beldar Helper',
                                        style: const TextStyle(color: kMuted, fontSize: 11),
                                      );
                                    } else if (serviceType == 'plumbing') {
                                      final bathrooms = customReqs['plot_area_sqft'] as num;
                                      final pipingType = customReqs['material_quality'];
                                      return Text(
                                        '${bathrooms.toStringAsFixed(0)} Bathrooms/Wet Areas · $pipingType · $materialText\n$workDays Days · $mistri Plumber + $beldar Helper',
                                        style: const TextStyle(color: kMuted, fontSize: 11),
                                      );
                                    } else if (serviceType == 'carpentry') {
                                      final area = customReqs['plot_area_sqft'] as num;
                                      final cabinetryType = customReqs['material_quality'];
                                      return Text(
                                        '${area.toStringAsFixed(1)} sqft Cabinets · $cabinetryType · $materialText\n$workDays Days · $mistri Badhai + $beldar Helper',
                                        style: const TextStyle(color: kMuted, fontSize: 11),
                                      );
                                    } else if (serviceType == 'painting') {
                                      final area = customReqs['plot_area_sqft'] as num;
                                      final paintGrade = customReqs['material_quality'];
                                      return Text(
                                        '${area.toStringAsFixed(0)} sqft Walls · $paintGrade · $materialText\n$workDays Days · $mistri Painter + $beldar Helper',
                                        style: const TextStyle(color: kMuted, fontSize: 11),
                                      );
                                    } else if (serviceType == 'flooring') {
                                      final area = customReqs['plot_area_sqft'] as num;
                                      final flooringType = customReqs['material_quality'];
                                      return Text(
                                        '${area.toStringAsFixed(0)} sqft Floor · $flooringType · $materialText\n$workDays Days · $mistri Tile Mistri + $beldar Helper',
                                        style: const TextStyle(color: kMuted, fontSize: 11),
                                      );
                                    } else {
                                      final plotArea = customReqs['plot_area_sqft'] as num;
                                      final materialQualityText = materialsSuppliedByGhulmil
                                          ? '${customReqs['material_quality']} Material'
                                          : 'Customer Material (Labor Only)';
                                      return Text(
                                        '${plotArea.toStringAsFixed(0)} sqft · $materialQualityText\n$workDays Days · $mistri Mistri + $beldar Beldar',
                                        style: const TextStyle(color: kMuted, fontSize: 11),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text('$currencySymbol${basePrice.toStringAsFixed(isCustomRequirement ? 0 : 2)}'),
                      ],
                    ),
                    const SizedBox(height: spacingSm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Taxes & Fees'),
                        Text('$currencySymbol${taxPrice.toStringAsFixed(isCustomRequirement ? 0 : 2)}'),
                      ],
                    ),
                    const Divider(height: spacing * 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          '$currencySymbol${totalPrice.toStringAsFixed(isCustomRequirement ? 0 : 2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: kPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
