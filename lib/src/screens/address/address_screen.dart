import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/constants.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/models/address.dart';
import 'package:ghulmil_application/src/providers/booking_provider.dart';
import 'package:ghulmil_application/src/services/location_gating_service.dart';
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

  // Offline-first Pithoragarh Address Database
  final List<Map<String, String>> _pithoragarhDatabase = const [
    {'name': 'Siltham Chauraha, Bhatkot', 'pincode': '262501', 'landmark': 'Near Petrol Pump'},
    {'name': 'Link Road, Naya Bazar', 'pincode': '262501', 'landmark': 'Near SBI Branch'},
    {'name': 'Purana Bazar, Dharamshala', 'pincode': '262501', 'landmark': 'Near Ramlila Ground'},
    {'name': 'GIC Road, Kumaur', 'pincode': '262501', 'landmark': 'Near Govt Inter College'},
    {'name': 'Wadda Village', 'pincode': '262501', 'landmark': 'Main Market'},
    {'name': 'Bhatkot Area', 'pincode': '262501', 'landmark': 'Near G.B. Pant Park'},
    {'name': 'Gurna Temple Area', 'pincode': '262501', 'landmark': 'Near National Highway'},
    {'name': 'Munsyari Town Center', 'pincode': '262502', 'landmark': 'Near Bus Stand'},
    {'name': 'Sarmoli Village', 'pincode': '262502', 'landmark': 'Near Homestay Association'},
    {'name': 'Darkot Craft Village', 'pincode': '262502', 'landmark': 'Near Shawl Weavers Association'},
    {'name': 'Madkot Hot Springs', 'pincode': '262502', 'landmark': 'Near Gori Ganga River'},
    {'name': 'Dharchula Town', 'pincode': '262510', 'landmark': 'Near Indo-Nepal Suspension Bridge'},
    {'name': 'Tawaghat Junction', 'pincode': '262510', 'landmark': 'Near Dhauliganga Dam'},
    {'name': 'Baluakot Bazar', 'pincode': '262510', 'landmark': 'Near Kali River Bank'},
    {'name': 'Jauljibi Border Trade Area', 'pincode': '262510', 'landmark': 'Near Trade Ground'},
    {'name': 'Didihat Town Dharamgarh Road', 'pincode': '262520', 'landmark': 'Near Tehsil Headquarters'},
    {'name': 'Sandev Temple Hill', 'pincode': '262520', 'landmark': 'Near View Point'},
    {'name': 'Adicha Village', 'pincode': '262520', 'landmark': 'Near Primary School'},
    {'name': 'Gangolihat Haat Kalika Temple', 'pincode': '262530', 'landmark': 'Near Main Entrance Gate'},
    {'name': 'Patal Bhuvaneshwar Caves', 'pincode': '262530', 'landmark': 'Near Cave Temple Office'},
    {'name': 'Berinag Tea Garden Road', 'pincode': '262540', 'landmark': 'Near Tea Factory'},
    {'name': 'Tripura Devi Bazar', 'pincode': '262540', 'landmark': 'Near Highway Temple'},
  ];

  // Search auto-complete state
  final _searchController = TextEditingController();
  List<Map<String, String>> _filteredSuggestions = [];
  bool _showSuggestions = false;

  // Mock saved addresses localized to Pithoragarh launchpad (Uttarakhand)
  final List<Address> _savedAddresses = [
    Address(
      id: 'addr_1',
      line1: 'Link Road, near Siltham',
      line2: 'Pithoragarh',
      city: 'Pithoragarh',
      state: 'Uttarakhand',
      postalCode: '262501',
      country: 'India',
    ),
    Address(
      id: 'addr_2',
      line1: 'Dharamgarh Road, near Post Office',
      line2: 'Didihat',
      city: 'Pithoragarh',
      state: 'Uttarakhand',
      postalCode: '262501',
      country: 'India',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (_savedAddresses.isNotEmpty) {
      _selectedSavedAddressId = _savedAddresses.first.id;
    }
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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    // TODO: Implement actual location permission check
    setState(() {
      _hasLocationPermission = true; // Mock for now
    });
  }

  Future<void> _submit() async {
    print('DEBUG: _submit called in address_screen');
    try {
      if (_showManualEntry || _savedAddresses.isEmpty) {
        if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
          print('DEBUG: manual address form validation failed');
          return;
        }
      } else {
        if (_selectedSavedAddressId == null) {
          print('DEBUG: no saved address selected');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an address or add a new one')),
          );
          return;
        }
      }

      print('DEBUG: constructing Address object for id=$_selectedSavedAddressId');
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
      print('DEBUG: constructed address=$address');

      final bookingNotifier = ref.read(bookingDraftProvider.notifier);
      bookingNotifier.setAddress(address);
      print('DEBUG: address set in bookingDraftProvider');

      // Navigate to payment screen
      print('DEBUG: navigating to payment screen via pushNamed');
      context.pushNamed('payment', pathParameters: {'bookingDraftId': 'draft-123'});
      print('DEBUG: context.pushNamed called successfully');
    } catch (e, stack) {
      print('DEBUG: Exception in _submit: $e');
      print('DEBUG: StackTrace: $stack');
    }
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
          // Address Autocomplete (Offline-first Local Search Index for Pithoragarh)
          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Local Village / Landmark (Pithoragarh)',
              hintText: 'e.g. Siltham, Sarmoli, Haat Kalika...',
              prefixIcon: const Icon(Icons.search, color: kPrimary),
              suffixIcon: _searchController.text.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _filteredSuggestions = [];
                        _showSuggestions = false;
                      });
                    },
                  )
                : const Icon(Icons.my_location, color: kPrimary),
            ),
            onChanged: (val) {
              if (val.trim().isEmpty) {
                setState(() {
                  _filteredSuggestions = [];
                  _showSuggestions = false;
                });
                return;
              }
              final query = val.toLowerCase().trim();
              final matches = _pithoragarhDatabase.where((item) {
                return item['name']!.toLowerCase().contains(query) ||
                       item['pincode']!.contains(query);
              }).toList();
              setState(() {
                _filteredSuggestions = matches;
                _showSuggestions = matches.isNotEmpty;
              });
            },
            validator: (value) => _line1Controller.text.isEmpty ? ValidationMessages.requiredField : null,
          ),
          if (_showSuggestions) ...[
            const SizedBox(height: spacingXs),
            Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _filteredSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _filteredSuggestions[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.location_on_outlined, color: kPrimary, size: 18),
                      title: Text(
                        suggestion['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kTextPrimary),
                      ),
                      subtitle: Text(
                        'PIN: ${suggestion['pincode']!} · ${suggestion['landmark']!}',
                        style: const TextStyle(fontSize: 10, color: kMuted),
                      ),
                      onTap: () {
                        setState(() {
                          _searchController.text = suggestion['name']!;
                          _line1Controller.text = suggestion['name']!;
                          _line2Controller.text = suggestion['landmark']!;
                          _cityController.text = 'Pithoragarh';
                          _postalCodeController.text = suggestion['pincode']!;
                          _showSuggestions = false;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
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
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ValidationMessages.requiredField;
                    }
                    if (!LocationGatingService.isPincodeServiced(value)) {
                      return 'Active only in Pithoragarh (Uttarakhand)';
                    }
                    return null;
                  },
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
