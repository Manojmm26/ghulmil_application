import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:ghulmil_application/src/models/slot.dart';
import 'package:ghulmil_application/src/providers/availability_provider.dart';
import 'package:ghulmil_application/src/providers/booking_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  final String serviceId;
  const ScheduleScreen({super.key, required this.serviceId});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Auto-start a new booking draft if none exists yet, so that reloading the page works perfectly
    Future.microtask(() {
      if (ref.read(bookingDraftProvider) == null) {
        ref.read(bookingDraftProvider.notifier).startDraft(widget.serviceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingDraft = ref.watch(bookingDraftProvider);
    print('DEBUG: schedule_screen build - draft=$bookingDraft, scheduledAt=${bookingDraft?.scheduledAt}');
    final bookingNotifier = ref.read(bookingDraftProvider.notifier);
    final availability = ref.watch(availabilityProvider((serviceId: widget.serviceId, date: _selectedDay!)));

    return Scaffold(
      appBar: AppBar(title: const Text('Select Date & Time')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: kAccent, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: kPrimary, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: spacing),
          Expanded(
            child: availability.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (slots) {
                final displaySlots = slots.isNotEmpty ? slots : [
                  Slot(
                    start: DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 9, 0),
                    end: DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 10, 0),
                    providerCount: 3,
                  ),
                  Slot(
                    start: DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 11, 0),
                    end: DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 12, 0),
                    providerCount: 3,
                  ),
                  Slot(
                    start: DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 13, 0),
                    end: DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 14, 0),
                    providerCount: 2,
                  ),
                  Slot(
                    start: DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 15, 0),
                    end: DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 16, 0),
                    providerCount: 4,
                  ),
                  Slot(
                    start: DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 17, 0),
                    end: DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 18, 0),
                    providerCount: 3,
                  ),
                ];

                return GridView.builder(
                  padding: const EdgeInsets.all(spacing),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                  ),
                  itemCount: displaySlots.length,
                  itemBuilder: (context, index) {
                    final slot = displaySlots[index];
                    final isSelected = bookingDraft?.scheduledAt == slot.start;
                    return ChoiceChip(
                      label: Text(DateFormat.jm().format(slot.start)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          bookingNotifier.setSlot(slot.start);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: bookingDraft?.scheduledAt != null
          ? Padding(
              padding: const EdgeInsets.all(spacing),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the next screen (e.g., address)
                  context.pushNamed('address');
                },
                child: const Text('Continue'),
              ),
            )
          : null,
    );
  }
}
