import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/constants.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/models/address.dart';
import 'package:ghulmil_application/src/providers/booking_provider.dart';
import 'package:go_router/go_router.dart';

enum AddressType { home, work, other }

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _accessNotesController = TextEditingController();
  final _gateCodeController = TextEditingController();

  String? _selectedSavedAddressId;
  bool _showManualEntry = false;
  bool _hasLocationPermission = false;

  // Mock saved addresses
  final List<Address> _savedAddresses = [
    Address(
      id: 'addr_1',
      line1: '123 Main Street',
      line2: 'Apartment 4B',
      city: 'New York',
      state: 'NY',
      postalCode: '10001',
      country: 'USA',
    ),
    Address(
      id: 'addr_2',
      line1: '456 Office Building',
      line2: 'Floor 10',
      city: 'New York',
      state: 'NY',
      postalCode: '10002',
      country: 'USA',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // TODO: Check location permission and services
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _accessNotesController.dispose();
    _gateCodeController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    // TODO: Implement actual location permission check
    setState(() {
      _hasLocationPermission = true; // Mock for now
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final address = Address(
      id: _selectedSavedAddressId ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      line1: _line1Controller.text.isEmpty ? _savedAddresses.firstWhere((addr) => addr.id == _selectedSavedAddressId).line1 : _line1Controller.text,
      line2: _line2Controller.text,
      city: _cityController.text.isEmpty ? _savedAddresses.firstWhere((addr) => addr.id == _selectedSavedAddressId).city : _cityController.text,
      state: 'NY', // TODO: Get from location or user input
      postalCode: _postalCodeController.text.isEmpty ? _savedAddresses.firstWhere((addr) => addr.id == _selectedSavedAddressId).postalCode : _postalCodeController.text,
      country: 'USA', // TODO: Get from location
      accessNotes: _accessNotesController.text.isEmpty ? null : _accessNotesController.text,
      gateCode: _gateCodeController.text.isEmpty ? null : _gateCodeController.text,
    );

    final bookingNotifier = ref.read(bookingDraftProvider.notifier);
    bookingNotifier.setAddress(address);

    // Navigate to payment screen
    context.go('/payment/draft-123');
  }

  Widget _buildSavedAddressesDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saved Addresses', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: spacingSm),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _savedAddresses.length,
          itemBuilder: (context, index) {
            final address = _savedAddresses[index];
            return SavedAddressTile(
              address: address,
              isSelected: _selectedSavedAddressId == address.id,
              onSelect: () {
                setState(() {
                  _selectedSavedAddressId = address.id;
                  _showManualEntry = false;
                });
              },
            );
          },
        ),
        const SizedBox(height: spacing),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _showManualEntry = true;
              _selectedSavedAddressId = null;
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New Address'),
        ),
      ],
    );
  }

  Widget _buildManualAddressForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address Autocomplete (placeholder for Google Places)
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Search Address',
              hintText: 'Enter address or use current location',
              prefixIcon: Icon(Icons.search),
              suffixIcon: Icon(Icons.my_location),
            ),
            onTap: () {
              // TODO: Implement Google Places autocomplete
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Google Places integration coming soon')),
              );
            },
            validator: (value) => value!.isEmpty ? ValidationMessages.requiredField : null,
          ),
          const SizedBox(height: spacing),

          // Manual address fields
          TextFormField(
            controller: _line1Controller,
            decoration: const InputDecoration(labelText: 'Address Line 1'),
            validator: (value) => value!.isEmpty ? ValidationMessages.requiredField : null,
          ),
          const SizedBox(height: spacing),
          TextFormField(
            controller: _line2Controller,
            decoration: const InputDecoration(labelText: 'Address Line 2 (Optional)'),
          ),
          const SizedBox(height: spacing),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (value) => value!.isEmpty ? ValidationMessages.requiredField : null,
                ),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: TextFormField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(labelText: 'Postal Code'),
                  validator: (value) => value!.isEmpty ? ValidationMessages.requiredField : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: spacing),

          // Access Information
          Text('Access Information (Optional)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: spacingSm),
          TextFormField(
            controller: _accessNotesController,
            decoration: const InputDecoration(
              labelText: 'Access Notes',
              hintText: 'e.g., Ring doorbell, building entrance code, etc.',
            ),
            maxLength: AppConstants.maxAddressNotesLength,
            maxLines: 3,
          ),
          const SizedBox(height: spacing),
          TextFormField(
            controller: _gateCodeController,
            decoration: const InputDecoration(
              labelText: 'Gate/Building Code',
              hintText: 'Enter code if applicable',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Address & Access')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location permission notice
            if (!_hasLocationPermission)
              Card(
                color: kDanger.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(spacing),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: kDanger),
                      const SizedBox(width: spacingSm),
                      Expanded(
                        child: Text(
                          ErrorMessages.locationPermissionDenied,
                          style: TextStyle(color: kDanger),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Open app settings or request permission
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Location permission required')),
                          );
                        },
                        child: const Text('Enable'),
                      ),
                    ],
                  ),
                ),
              ),

            // Saved addresses
            if (_savedAddresses.isNotEmpty) ...[
              _buildSavedAddressesDropdown(),
              const SizedBox(height: spacingLg),
              const Divider(),
              const SizedBox(height: spacingLg),
            ],

            // Manual entry form
            if (_showManualEntry || _savedAddresses.isEmpty)
              _buildManualAddressForm(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(spacing),
        child: ElevatedButton(
          onPressed: _submit,
          child: const Text('Continue to Payment'),
        ),
      ),
    );
  }
}

class SavedAddressTile extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onSelect;

  const SavedAddressTile({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          color: isSelected ? kPrimary : kMuted,
        ),
        title: Text(
          address.line1,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('${address.city}, ${address.postalCode}'),
        trailing: isSelected ? Icon(Icons.check_circle, color: kPrimary) : null,
        onTap: onSelect,
        tileColor: isSelected ? kPrimary.withOpacity(0.1) : null,
      ),
    );
  }
}
