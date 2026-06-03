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
  String _selectedMethod = 'upi'; // Default to UPI as requested
  late TextEditingController _upiController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _upiController = TextEditingController(text: 'customer@okaxis');
  }

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndPay() async {
    if (_selectedMethod == 'upi') {
      if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
        return;
      }
    }

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

  Widget _buildUpiAppLogo(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ],
      ),
    );
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
            
            // Option 1: Pay via UPI
            GestureDetector(
              onTap: () => setState(() => _selectedMethod = 'upi'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(spacing),
                decoration: BoxDecoration(
                  color: _selectedMethod == 'upi' ? kPrimary.withOpacity(0.04) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedMethod == 'upi' ? kPrimary : Colors.grey[300]!,
                    width: _selectedMethod == 'upi' ? 2.0 : 1.0,
                  ),
                  boxShadow: [
                    if (_selectedMethod == 'upi')
                      BoxShadow(
                        color: kPrimary.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(spacingSm),
                          decoration: BoxDecoration(
                            color: _selectedMethod == 'upi' ? kPrimary.withOpacity(0.12) : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.qr_code_scanner,
                            color: _selectedMethod == 'upi' ? kPrimary : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: spacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pay via UPI',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              Text(
                                'GPay, PhonePe, Paytm, BHIM',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Radio<String>(
                          value: 'upi',
                          groupValue: _selectedMethod,
                          activeColor: kPrimary,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedMethod = val);
                          },
                        ),
                      ],
                    ),
                    if (_selectedMethod == 'upi') ...[
                      const Divider(height: 24),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _upiController,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Enter UPI ID (VPA)',
                            hintText: 'username@bank',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.alternate_email, color: kPrimary, size: 20),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter your UPI ID';
                            }
                            if (!val.contains('@')) {
                              return 'Invalid UPI ID (must contain @)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Quick tags
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['@okaxis', '@okicici', '@paytm', '@okdhfcbank'].map((suffix) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InkWell(
                                onTap: () {
                                  final current = _upiController.text;
                                  if (current.contains('@')) {
                                    final parts = current.split('@');
                                    if (parts[0].isNotEmpty) {
                                      _upiController.text = parts[0] + suffix;
                                    } else {
                                      _upiController.text = 'customer' + suffix;
                                    }
                                  } else {
                                    _upiController.text = (current.isEmpty ? 'customer' : current) + suffix;
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: kPrimary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: kPrimary.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    suffix,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildUpiAppLogo('GPay', Colors.blue[800]!),
                          _buildUpiAppLogo('PhonePe', Colors.deepPurple),
                          _buildUpiAppLogo('Paytm', Colors.blue[600]!),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: spacingSm),
            
            // Option 2: Cash on Completion
            GestureDetector(
              onTap: () => setState(() => _selectedMethod = 'cash'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(spacing),
                decoration: BoxDecoration(
                  color: _selectedMethod == 'cash' ? kSuccess.withOpacity(0.04) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedMethod == 'cash' ? kSuccess : Colors.grey[300]!,
                    width: _selectedMethod == 'cash' ? 2.0 : 1.0,
                  ),
                  boxShadow: [
                    if (_selectedMethod == 'cash')
                      BoxShadow(
                        color: kSuccess.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(spacingSm),
                          decoration: BoxDecoration(
                            color: _selectedMethod == 'cash' ? kSuccess.withOpacity(0.12) : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.payments,
                            color: _selectedMethod == 'cash' ? kSuccess : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: spacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cash on Completion',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              Text(
                                'Pay the Mistri directly after service',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Radio<String>(
                          value: 'cash',
                          groupValue: _selectedMethod,
                          activeColor: kSuccess,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedMethod = val);
                          },
                        ),
                      ],
                    ),
                    if (_selectedMethod == 'cash') ...[
                      const Divider(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.handshake, color: kSuccess, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Zero advance payment required. Safely pay ₹${totalPrice.toStringAsFixed(0)} in cash or local personal UPI to the provider once your work is completely done.',
                                style: TextStyle(color: Colors.green[900], fontSize: 11, height: 1.4, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: spacingSm),

            // Option 3: Saved Credit / Debit Card
            GestureDetector(
              onTap: () => setState(() => _selectedMethod = 'card'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(spacing),
                decoration: BoxDecoration(
                  color: _selectedMethod == 'card' ? kPrimary.withOpacity(0.04) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedMethod == 'card' ? kPrimary : Colors.grey[300]!,
                    width: _selectedMethod == 'card' ? 2.0 : 1.0,
                  ),
                  boxShadow: [
                    if (_selectedMethod == 'card')
                      BoxShadow(
                        color: kPrimary.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(spacingSm),
                          decoration: BoxDecoration(
                            color: _selectedMethod == 'card' ? kPrimary.withOpacity(0.12) : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.credit_card,
                            color: _selectedMethod == 'card' ? kPrimary : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: spacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Saved Card **** 1234',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              Text(
                                'Visa ending in 1234',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Radio<String>(
                          value: 'card',
                          groupValue: _selectedMethod,
                          activeColor: kPrimary,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedMethod = val);
                          },
                        ),
                      ],
                    ),
                    if (_selectedMethod == 'card') ...[
                      const Divider(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline, color: kMuted, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Secured by standard gateway. Your card will be charged upon scheduling confirmation.',
                                style: TextStyle(color: Colors.grey[800], fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
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
