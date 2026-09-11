import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env.dart';
import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../places/address_search_field.dart';
import 'booking_flow_controller.dart';

/// Step one: where, when, how many.
///
/// Mirrors the website's search widget field for field, because the server
/// validates both against the same rules — a journey the site would refuse is
/// refused here for the same reason, with the same message.
class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingFlowProvider);
    final controller = ref.read(bookingFlowProvider.notifier);
    final journey = state.journey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a transfer'),
        actions: [
          IconButton(
            tooltip: 'My trips',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => context.push('/trips'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          if (Env.isDevelopmentBackend)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('Connected to ${Env.apiBaseUrl}', style: const TextStyle(color: AppTheme.inkMuted, fontSize: 12)),
            ),
          const SectionTitle('Where are you going?', subtitle: 'The price you see is the price you pay. No account needed to get a quote.'),
          const SizedBox(height: 16),
          AddressField(
            label: 'Pickup',
            icon: Icons.my_location,
            value: journey.pickup,
            onChanged: (place) => controller.updateJourney((j) => j.copyWith(pickup: place)),
          ),
          for (var i = 0; i < journey.via.length; i++) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AddressField(
                    label: 'Stop ${i + 1}',
                    icon: Icons.add_location_alt_outlined,
                    value: journey.via[i],
                    onChanged: (place) => controller.updateJourney((j) => j.setViaStop(i, place)),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove stop',
                  icon: const Icon(Icons.close),
                  onPressed: () => controller.updateJourney((j) => j.removeViaStop(i)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          AddressField(
            label: 'Destination',
            icon: Icons.flag_outlined,
            value: journey.dropoff,
            onChanged: (place) => controller.updateJourney((j) => j.copyWith(dropoff: place)),
          ),
          if (journey.canAddViaStop)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => controller.updateJourney((j) => j.addViaStop()),
                icon: const Icon(Icons.add, size: 18),
                label: Text(journey.via.isEmpty ? 'Add a stop on the way' : 'Add another stop'),
              ),
            ),
          const SizedBox(height: 24),
          const SectionTitle('When?'),
          const SizedBox(height: 12),
          _DateTimeRow(
            date: journey.pickupDate,
            time: journey.pickupTime,
            onDate: (d) => controller.updateJourney((j) => j.copyWith(pickupDate: d)),
            onTime: (t) => controller.updateJourney((j) => j.copyWith(pickupTime: t)),
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Add a return journey'),
            subtitle: const Text('Same vehicle, same price each way'),
            value: journey.isReturn,
            onChanged: (on) => controller.updateJourney((j) => on ? j.copyWith(isReturn: true) : j.withoutReturn()),
          ),
          if (journey.isReturn) ...[
            const SizedBox(height: 4),
            _DateTimeRow(
              date: journey.returnDate,
              time: journey.returnTime,
              firstDate: journey.pickupDate,
              onDate: (d) => controller.updateJourney((j) => j.copyWith(returnDate: d)),
              onTime: (t) => controller.updateJourney((j) => j.copyWith(returnTime: t)),
            ),
          ],
          const SizedBox(height: 24),
          const SectionTitle('Who is travelling?'),
          const SizedBox(height: 8),
          CountStepper(
            label: 'Passengers',
            value: journey.passengerCount,
            min: 1,
            max: 8,
            onChanged: (v) => controller.updateJourney((j) => j.copyWith(passengerCount: v)),
          ),
          CountStepper(
            label: 'Large suitcases',
            value: journey.luggageCount,
            min: 0,
            max: 8,
            onChanged: (v) => controller.updateJourney((j) => j.copyWith(luggageCount: v)),
          ),
          if (journey.touchesAirport) ...[
            const SizedBox(height: 24),
            const SectionTitle('Flight details', subtitle: 'Optional. On an airport pickup we track the flight and adjust your pickup time.'),
            const SizedBox(height: 12),
            _FlightFields(
              flightNumber: journey.outboundFlightNumber,
              terminal: journey.outboundTerminal,
              onFlight: (v) => controller.updateJourney((j) => j.copyWith(outboundFlightNumber: v)),
              onTerminal: (v) => controller.updateJourney((j) => j.copyWith(outboundTerminal: v)),
            ),
          ],
          if (state.quoteError != null) ...[
            const SizedBox(height: 16),
            ErrorNotice(state.quoteError!),
          ],
        ],
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: journey.isQuotable && !state.isQuoting
              ? () async {
                  if (await controller.requestQuote() && context.mounted) {
                    context.push('/book/vehicle');
                  }
                }
              : null,
          child: state.isQuoting
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : const Text('See prices'),
        ),
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({
    required this.date,
    required this.time,
    required this.onDate,
    required this.onTime,
    this.firstDate,
  });

  final DateTime? date;
  final TimeOfDay? time;
  final DateTime? firstDate;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<TimeOfDay> onTime;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final earliest = firstDate ?? DateTime(today.year, today.month, today.day);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _PickerTile(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: date == null ? null : Formatting.date(date!),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date ?? (earliest.isAfter(today) ? earliest : today),
                firstDate: earliest,
                lastDate: today.add(const Duration(days: 365)),
              );
              if (picked != null) onDate(picked);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _PickerTile(
            icon: Icons.schedule_outlined,
            label: 'Time',
            value: time?.format(context),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time ?? const TimeOfDay(hour: 9, minute: 0),
                builder: (context, child) => MediaQuery(
                  // The server takes 24-hour time; showing it that way avoids
                  // a customer reading "9:00" and meaning the evening.
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                ),
              );
              if (picked != null) onTime(picked);
            },
          ),
        ),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({required this.icon, required this.label, required this.value, required this.onTap});

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        isEmpty: value == null,
        child: Text(value ?? ''),
      ),
    );
  }
}

class _FlightFields extends StatelessWidget {
  const _FlightFields({required this.flightNumber, required this.terminal, required this.onFlight, required this.onTerminal});

  final String? flightNumber;
  final String? terminal;
  final ValueChanged<String> onFlight;
  final ValueChanged<String> onTerminal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: flightNumber,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Flight number', hintText: 'BA123'),
            onChanged: onFlight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            initialValue: terminal,
            decoration: const InputDecoration(labelText: 'Terminal', hintText: 'T5'),
            onChanged: onTerminal,
          ),
        ),
      ],
    );
  }
}
