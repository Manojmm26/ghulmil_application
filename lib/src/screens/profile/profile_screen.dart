import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/models/booking.dart';
import 'package:ghulmil_application/src/providers/auth_provider.dart';
import 'package:ghulmil_application/src/providers/booking_details_provider.dart';
import 'package:ghulmil_application/src/providers/api_client_provider.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${_formatTime(dt)}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute < 10 ? '0${dt.minute}' : '${dt.minute}';
    return '$hour:$minute $amPm';
  }

  void _showEditProfileDialog(Map<String, dynamic> profile) {
    final nameController = TextEditingController(text: profile['full_name'] ?? '');
    final phoneController = TextEditingController(text: profile['phone'] ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Profile Details', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    enabled: !isSaving,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    enabled: !isSaving,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setState(() {
                            isSaving = true;
                          });

                          try {
                            final success = await ref.read(apiClientProvider).updateUserProfile(
                                  fullName: nameController.text,
                                  phone: phoneController.text,
                                );

                            if (success) {
                              ref.invalidate(userProfileProvider);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Profile updated successfully!')),
                                );
                              }
                            } else {
                              throw Exception('Update failed');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update: $e')),
                              );
                            }
                          } finally {
                            setState(() {
                              isSaving = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final bookingsAsync = ref.watch(userBookingsProvider);
    final authState = ref.watch(authStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kDanger),
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(authStateNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.goNamed('signin');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Details Header Card
          profileAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(spacing),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => Card(
              margin: const EdgeInsets.all(spacing),
              child: Padding(
                padding: const EdgeInsets.all(spacing),
                child: Text('Error: $err'),
              ),
            ),
            data: (profile) {
              final userProfile = profile ?? {};
              final fullName = userProfile['full_name'] ?? authState.user?.email?.split('@').first ?? 'Ghulmil User';
              final phone = userProfile['phone'] ?? 'Add phone number';
              final email = authState.user?.email ?? 'No email associated';
              final initials = fullName.isNotEmpty ? fullName.substring(0, 1).toUpperCase() : 'G';

              return Container(
                margin: const EdgeInsets.all(spacing),
                padding: const EdgeInsets.all(spacing),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimary, kPrimary.withBlue(180)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: spacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.email_outlined, size: 14, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      email,
                                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 14, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    phone,
                                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_square, color: Colors.white),
                          onPressed: () => _showEditProfileDialog(userProfile),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Booking History Tab Header
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: kPrimary,
              unselectedLabelColor: kMuted,
              indicatorColor: kPrimary,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.engineering_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Active Work', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off, size: 18),
                      SizedBox(width: 8),
                      Text('Completed', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab View containing active and past lists
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userBookingsProvider);
                ref.invalidate(userProfileProvider);
              },
              child: bookingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error loading history: $err')),
                data: (bookings) {
                  final active = bookings
                      .where((b) =>
                          b.status == BookingStatus.pending ||
                          b.status == BookingStatus.confirmed ||
                          b.status == BookingStatus.enroute ||
                          b.status == BookingStatus.inProgress)
                      .toList();

                  final past = bookings
                      .where((b) => b.status == BookingStatus.completed || b.status == BookingStatus.cancelled)
                      .toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookingsList(active, isActive: true),
                      _buildBookingsList(past, isActive: false),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> list, {required bool isActive}) {
    if (list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? Icons.engineering_outlined : Icons.inventory_2_outlined,
                  size: 64,
                  color: kMuted.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  isActive ? 'No active site jobs' : 'No past bookings found',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kMuted),
                ),
                const SizedBox(height: 8),
                Text(
                  isActive ? 'Book a structural or renovation service to start.' : 'Your complete job bills will show here.',
                  style: const TextStyle(fontSize: 12, color: kMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (isActive)
                  ElevatedButton.icon(
                    onPressed: () => context.goNamed('home'),
                    icon: const Icon(Icons.search),
                    label: const Text('Browse Services'),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(spacing),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: spacing),
      itemBuilder: (context, index) {
        final booking = list[index];
        return _buildBookingCard(booking, isActive: isActive);
      },
    );
  }

  Widget _buildBookingCard(Booking booking, {required bool isActive}) {
    // Try parsing custom requirements from draft notes
    Map<String, dynamic>? customReqs;
    if (booking.notes != null) {
      try {
        customReqs = jsonDecode(booking.notes!);
      } catch (_) {}
    }

    final bool isCustom = customReqs != null && customReqs['service_type'] != null;
    String serviceName = 'Home Deep Clean';
    String descriptionText = 'Standard Clean Package';

    if (isCustom) {
      final type = customReqs['service_type'];
      final workDays = customReqs['work_days'] ?? 1;
      final mistri = customReqs['raj_mistri_count'] ?? 1;
      final beldar = customReqs['beldar_count'] ?? 1;

      if (type == 'electrical') {
        serviceName = 'MEP: Electrical Work (Bijli Fitting)';
        final points = customReqs['plot_area_sqft'] ?? 0;
        final stageText = customReqs['material_quality'] ?? 'Standard';
        descriptionText = '${(points as num).toStringAsFixed(0)} Points · $stageText\n$workDays Days · $mistri Electrician + $beldar helper';
      } else if (type == 'plumbing') {
        serviceName = 'MEP: Plumbing Work (Nal aur Sanitary)';
        final bathrooms = customReqs['plot_area_sqft'] ?? 0;
        final pipingType = customReqs['material_quality'] ?? 'Standard';
        descriptionText = '${(bathrooms as num).toStringAsFixed(0)} Bathrooms · $pipingType\n$workDays Days · $mistri Plumber + $beldar helper';
      } else if (type == 'carpentry') {
        serviceName = 'Interior: Carpentry Woodwork (Badhai)';
        final area = customReqs['plot_area_sqft'] ?? 0;
        final cabinetryType = customReqs['material_quality'] ?? 'Standard';
        descriptionText = '${(area as num).toStringAsFixed(1)} sqft Cabinets · $cabinetryType\n$workDays Days · $mistri Badhai + $beldar helper';
      } else if (type == 'painting') {
        serviceName = 'Interior: Wall Painting (Rangai Putty)';
        final area = customReqs['plot_area_sqft'] ?? 0;
        final paintGrade = customReqs['material_quality'] ?? 'Standard';
        descriptionText = '${(area as num).toStringAsFixed(0)} sqft Wall Area · $paintGrade\n$workDays Days · $mistri Painter + $beldar helper';
      } else if (type == 'flooring') {
        serviceName = 'Interior: Tile & Marble flooring';
        final area = customReqs['plot_area_sqft'] ?? 0;
        final flooringType = customReqs['material_quality'] ?? 'Standard';
        descriptionText = '${(area as num).toStringAsFixed(0)} sqft Floor · $flooringType\n$workDays Days · $mistri Tile-Mistri + $beldar helper';
      } else {
        serviceName = 'Civil Masonry & Concrete (Lenter/Chunai)';
        final plotArea = customReqs['plot_area_sqft'] ?? 0;
        final isGhulmilMaterial = customReqs['materials_supplied_by_ghulmil'] as bool? ?? true;
        final materialQualityText = isGhulmilMaterial
            ? '${customReqs['material_quality']} Material'
            : 'Customer Material (Labor Only)';
        descriptionText = '${(plotArea as num).toStringAsFixed(0)} sqft · $materialQualityText\n$workDays Days · $mistri Mason + $beldar helper';
      }
    }

    final double totalAmount = booking.price?.total ?? 49.99;
    final String currencySymbol = isCustom ? '₹' : '\$';
    final String priceText = isCustom ? '$currencySymbol${totalAmount.toStringAsFixed(0)}' : '$currencySymbol${totalAmount.toStringAsFixed(2)}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(booking.status),
                Text(
                  priceText,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimary),
                ),
              ],
            ),
            const SizedBox(height: spacingSm),
            Text(
              serviceName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              descriptionText,
              style: const TextStyle(fontSize: 11, color: kMuted),
            ),
            const Divider(height: spacing * 2),

            // Time Row
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: kMuted),
                const SizedBox(width: 6),
                Text(
                  booking.scheduledAt != null ? _formatDateTime(booking.scheduledAt!) : 'Not scheduled yet',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kTextPrimary),
                ),
              ],
            ),

            if (isActive || booking.status == BookingStatus.completed) ...[
              const SizedBox(height: spacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isActive) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        // Simulated chat link
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Connecting to site contractor...')),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 14),
                      label: const Text('Contact Site'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => context.goNamed('tracking', pathParameters: {'bookingId': booking.id}),
                      icon: const Icon(Icons.gps_fixed_outlined, size: 14),
                      label: const Text('Track Progress'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: () => context.goNamed('review', pathParameters: {'bookingId': booking.id}),
                      icon: const Icon(Icons.star_rate_outlined, size: 14),
                      label: const Text('Rate Service'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color color;
    String label;

    switch (status) {
      case BookingStatus.pending:
        color = kAccent;
        label = 'Pending';
        break;
      case BookingStatus.confirmed:
        color = Colors.blue;
        label = 'Confirmed';
        break;
      case BookingStatus.enroute:
        color = Colors.purple;
        label = 'Enroute';
        break;
      case BookingStatus.inProgress:
        color = Colors.teal;
        label = 'On-site Progress';
        break;
      case BookingStatus.completed:
        color = kSuccess;
        label = 'Completed';
        break;
      case BookingStatus.cancelled:
        color = kDanger;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
