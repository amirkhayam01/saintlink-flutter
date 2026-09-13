import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env.dart';
import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../domain/place.dart';
import '../../widgets/common.dart';
import '../../widgets/tiles.dart';
import '../places/address_search_field.dart';
import 'booking_flow_controller.dart';
import 'journey_draft.dart';

/// The booking form: where, when, who — then "See prices".
///
/// The form mirrors the website's search widget field for field, because the
/// server validates both against the same rules — a journey the site would
/// refuse is refused here for the same reason, with the same message.
class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingFlowProvider);
    final controller = ref.read(bookingFlowProvider.notifier);
    final journey = state.journey;
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a transfer'),
        actions: [
          if (!journey.pickup.isEmpty || !journey.dropoff.isEmpty || journey.pickupDate != null)
            TextButton(
              onPressed: controller.reset,
              child: Text('Clear', style: TextStyle(color: colors.inkMuted)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          Text('Where to?', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          _RouteEditor(journey: journey, controller: controller),
          const SizedBox(height: 20),
          Text('When?', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          _DateTimeRow(
            date: journey.pickupDate,
            time: journey.pickupTime,
            onDate: (d) => controller.updateJourney((j) => j.copyWith(pickupDate: d)),
            onTime: (t) => controller.updateJourney((j) => j.copyWith(pickupTime: t)),
          ),
          const SizedBox(height: 10),
          if (journey.isReturn)
            _ReturnCard(journey: journey, controller: controller)
          else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => controller.updateJourney((j) => j.copyWith(isReturn: true)),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add return journey'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.brandDark),
              ),
            ),
          const SizedBox(height: 20),
          Text('Who?', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          FieldTile(
            icon: Icons.people_outline,
            label: 'Passengers & luggage',
            value: _travellersLabel(journey),
            placeholder: '',
            onTap: () => _showTravellers(context, controller),
          ),
          if (journey.touchesAirport) ...[
            const SizedBox(height: 20),
            _FlightFields(
              flightNumber: journey.outboundFlightNumber,
              terminal: journey.outboundTerminal,
              onFlight: (v) => controller.updateJourney((j) => j.copyWith(outboundFlightNumber: v)),
              onTerminal: (v) => controller.updateJourney((j) => j.copyWith(outboundTerminal: v)),
            ),
          ],
          if (state.quoteError != null) ...[const SizedBox(height: 16), ErrorNotice(state.quoteError!)],
          if (Env.isDevelopmentBackend) ...[
            const SizedBox(height: 24),
            Text('Connected to ${Env.apiBaseUrl}', textAlign: TextAlign.center, style: TextStyle(color: colors.inkMuted, fontSize: 11)),
          ],
        ],
      ),
      bottomNavigationBar: BottomAction(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: journey.isQuotable && !state.isQuoting
                  ? () async {
                      if (await controller.requestQuote() && context.mounted) context.push('/book/vehicle');
                    }
                  : null,
              child: state.isQuoting ? const ButtonSpinner() : const Text('See prices'),
            ),
            const SizedBox(height: 8),
            Text('Fixed price. No account needed for a quote.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  String _travellersLabel(JourneyDraft j) {
    final p = '${j.passengerCount} passenger${j.passengerCount == 1 ? '' : 's'}';
    final l = j.luggageCount == 0 ? 'no large cases' : '${j.luggageCount} large case${j.luggageCount == 1 ? '' : 's'}';

    return '$p · $l';
  }

  Future<void> _showTravellers(BuildContext context, BookingFlowController controller) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final j = ref.watch(bookingFlowProvider.select((s) => s.journey));

          return Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.paddingOf(context).bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Who is travelling?', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('We only show vehicles with room for everyone and everything.', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                CountStepper(label: 'Passengers', value: j.passengerCount, min: 1, max: 8, onChanged: (v) => controller.updateJourney((d) => d.copyWith(passengerCount: v))),
                CountStepper(label: 'Large suitcases', value: j.luggageCount, min: 0, max: 8, onChanged: (v) => controller.updateJourney((d) => d.copyWith(luggageCount: v))),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The return leg, inset in a tinted card with its own date and time and a
/// way to take it off again.
class _ReturnCard extends StatelessWidget {
  const _ReturnCard({required this.journey, required this.controller});

  final JourneyDraft journey;
  final BookingFlowController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 14),
      decoration: BoxDecoration(
        color: colors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.swap_vert, size: 18, color: AppTheme.brandDark),
              const SizedBox(width: 8),
              Expanded(child: Text('Return journey', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: colors.ink))),
              IconButton(
                onPressed: () => controller.updateJourney((j) => j.withoutReturn()),
                icon: Icon(Icons.close, size: 18, color: colors.inkMuted),
                tooltip: 'Remove return',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _DateTimeRow(
              date: journey.returnDate,
              time: journey.returnTime,
              firstDate: journey.pickupDate,
              dateLabel: 'Date',
              timeLabel: 'Time',
              onDate: (d) => controller.updateJourney((j) => j.copyWith(returnDate: d)),
              onTime: (t) => controller.updateJourney((j) => j.copyWith(returnTime: t)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pickup, stops and destination as one connected route.
class _RouteEditor extends StatelessWidget {
  const _RouteEditor({required this.journey, required this.controller});

  final JourneyDraft journey;
  final BookingFlowController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rows = <Widget>[
      _RouteStop(
        marker: _Marker.pickup,
        label: 'Pickup',
        value: journey.pickup,
        onChanged: (p) => controller.updateJourney((j) => j.copyWith(pickup: p)),
      ),
      for (var i = 0; i < journey.via.length; i++)
        _RouteStop(
          marker: _Marker.via,
          label: 'Stop ${i + 1}',
          value: journey.via[i],
          onChanged: (p) => controller.updateJourney((j) => j.setViaStop(i, p)),
          onRemove: () => controller.updateJourney((j) => j.removeViaStop(i)),
        ),
      _RouteStop(
        marker: _Marker.dropoff,
        label: 'Destination',
        value: journey.dropoff,
        onChanged: (p) => controller.updateJourney((j) => j.copyWith(dropoff: p)),
      ),
    ];

    return Container(
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.inkFaint)),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Padding(padding: const EdgeInsets.only(left: 52), child: Divider(color: colors.inkFaint)),
            rows[i],
          ],
          if (journey.canAddViaStop)
            Padding(
              padding: const EdgeInsets.only(left: 44, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => controller.updateJourney((j) => j.addViaStop()),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(journey.via.isEmpty ? 'Add a stop' : 'Add another stop'),
                  style: TextButton.styleFrom(foregroundColor: colors.inkMuted, textStyle: Theme.of(context).textButtonTheme.style?.textStyle?.resolve({})?.copyWith(fontSize: 13), padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 36)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _Marker { pickup, via, dropoff }

class _RouteStop extends StatelessWidget {
  const _RouteStop({required this.marker, required this.label, required this.value, required this.onChanged, this.onRemove});

  final _Marker marker;
  final String label;
  final PlaceSelection value;
  final ValueChanged<PlaceSelection> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final selection = await Navigator.of(context).push<PlaceSelection>(
          MaterialPageRoute(fullscreenDialog: true, builder: (_) => AddressSearchScreen(title: label, initial: value)),
        );
        if (selection != null) onChanged(selection);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            SizedBox(width: 20, child: Center(child: _MarkerDot(marker))),
            const SizedBox(width: 16),
            Expanded(
              child: value.isEmpty
                  ? Text(label, style: TextStyle(color: colors.inkMuted, fontSize: 16))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label.toUpperCase(), style: TextStyle(color: colors.inkMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                        const SizedBox(height: 2),
                        Text(value.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
            ),
            if (onRemove != null)
              IconButton(icon: Icon(Icons.close, size: 18, color: colors.inkMuted), onPressed: onRemove, tooltip: 'Remove stop')
            else if (!value.isEmpty && !value.isLocated)
              Tooltip(message: 'Pick a suggestion for the most accurate price', child: Icon(Icons.info_outline, size: 18, color: AppTheme.brandDark))
            else
              const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}

class _MarkerDot extends StatelessWidget {
  const _MarkerDot(this.marker);

  final _Marker marker;

  @override
  Widget build(BuildContext context) {
    return switch (marker) {
      _Marker.pickup => Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: context.colors.ink, width: 2.5))),
      _Marker.via => Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.inkMuted)),
      _Marker.dropoff => Container(width: 12, height: 12, decoration: BoxDecoration(color: AppTheme.brand, borderRadius: BorderRadius.circular(3), border: Border.all(color: context.colors.ink, width: 2))),
    };
  }
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({
    required this.date,
    required this.time,
    required this.onDate,
    required this.onTime,
    this.firstDate,
    this.dateLabel = 'Pickup date',
    this.timeLabel = 'Pickup time',
  });

  final DateTime? date;
  final TimeOfDay? time;
  final DateTime? firstDate;
  final String dateLabel;
  final String timeLabel;
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
          child: FieldTile(
            dense: true,
            icon: Icons.calendar_today_outlined,
            label: dateLabel,
            value: date == null ? null : Formatting.date(date!),
            placeholder: 'Choose a date',
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
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: FieldTile(
            dense: true,
            icon: Icons.schedule_outlined,
            label: timeLabel,
            value: time == null ? null : MaterialLocalizations.of(context).formatTimeOfDay(time!, alwaysUse24HourFormat: true),
            placeholder: 'Time',
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

class _FlightFields extends StatelessWidget {
  const _FlightFields({required this.flightNumber, required this.terminal, required this.onFlight, required this.onTerminal});

  final String? flightNumber;
  final String? terminal;
  final ValueChanged<String> onFlight;
  final ValueChanged<String> onTerminal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Flight details (optional) — we track it and adjust your pickup.', style: Theme.of(context).textTheme.bodySmall),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: flightNumber,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(hintText: 'Flight no. e.g. BA123', prefixIcon: Icon(Icons.flight_takeoff, size: 20)),
                onChanged: onFlight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: terminal,
                decoration: const InputDecoration(hintText: 'Terminal'),
                onChanged: onTerminal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
