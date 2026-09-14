import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../domain/place.dart';
import '../../widgets/common.dart';
import '../../widgets/inner_screen_header.dart';
import '../places/address_search_field.dart';
import 'booking_flow_controller.dart';
import 'booking_screen_header.dart';
import 'journey_draft.dart';
import 'journey_date_time_sheet.dart';

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

    return Scaffold(
      appBar: BookingScreenHeader(
        journey: journey,
        title: 'Plan your journey',
        onBack: () => context.go('/'),
        actions: [
          if (!journey.pickup.isEmpty ||
              !journey.dropoff.isEmpty ||
              journey.pickupDate != null)
            IconButton(
              tooltip: 'Clear journey',
              onPressed: controller.reset,
              icon: const Icon(Icons.restart_alt_rounded),
            ),
        ],
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
        children: [
          const BookingProgress(step: 0),
          const SizedBox(height: 20),
          _RouteEditor(journey: journey, controller: controller),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _JourneyDateTimeField(
                date: journey.pickupDate,
                time: journey.pickupTime,
                minimum: DateTime.now(),
                title: 'Pickup date & time',
                onChanged: (value) => controller.updateJourney(
                  (j) => j.copyWith(
                    pickupDate: DateUtils.dateOnly(value),
                    pickupTime: TimeOfDay.fromDateTime(value),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Return journey',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                activeTrackColor: context.colors.accent.withValues(alpha: 0.3),
                activeThumbColor: context.colors.accent,
                value: journey.isReturn,
                onChanged: (value) => controller.updateJourney(
                  (j) => value ? j.copyWith(isReturn: true) : j.withoutReturn(),
                ),
              ),
              if (journey.isReturn)
                _ReturnCard(journey: journey, controller: controller),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CountStepper(
                label: 'Passengers',
                value: journey.passengerCount,
                min: 1,
                max: 8,
                onChanged: (v) => controller.updateJourney(
                  (j) => j.copyWith(passengerCount: v),
                ),
              ),
              const SizedBox(height: 8),
              CountStepper(
                label: 'Large suitcases',
                value: journey.luggageCount,
                min: 0,
                max: 8,
                onChanged: (v) => controller.updateJourney(
                  (j) => j.copyWith(luggageCount: v),
                ),
              ),
            ],
          ),
          if (state.quoteError != null) ...[
            const SizedBox(height: 16),
            ErrorNotice(state.quoteError!),
          ],
        ],
      ),
      bottomNavigationBar: BottomAction(
        verticalPadding: 8,
        child: FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: journey.isQuotable && !state.isQuoting
              ? () async {
                  if (await controller.requestQuote() && context.mounted) {
                    context.push('/book/vehicle');
                  }
                }
              : null,
          child: state.isQuoting
              ? const ButtonSpinner()
              : const Text('Continue'),
        ),
      ),
    );
  }
}

/// Return date and time, shown below the return journey switch.
class _ReturnCard extends StatelessWidget {
  const _ReturnCard({required this.journey, required this.controller});

  final JourneyDraft journey;
  final BookingFlowController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: _JourneyDateTimeField(
        date: journey.returnDate,
        time: journey.returnTime,
        title: 'Return date & time',
        minimum: journey.pickupDate == null
            ? DateTime.now()
            : DateTime(
                journey.pickupDate!.year,
                journey.pickupDate!.month,
                journey.pickupDate!.day,
                journey.pickupTime?.hour ?? 0,
                journey.pickupTime?.minute ?? 0,
              ).add(const Duration(minutes: 1)),
        onChanged: (value) => controller.updateJourney(
          (j) => j.copyWith(
            returnDate: DateUtils.dateOnly(value),
            returnTime: TimeOfDay.fromDateTime(value),
          ),
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your route',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.ink,
                ),
              ),
            ),
            Tooltip(
              message: 'Swap pickup and destination',
              child: TextButton.icon(
                onPressed: journey.pickup.isEmpty && journey.dropoff.isEmpty
                    ? null
                    : () => controller.updateJourney(
                        (j) => j.copyWith(
                          pickup: j.dropoff,
                          dropoff: j.pickup,
                          via: j.via.reversed.toList(),
                        ),
                      ),
                icon: const Icon(Icons.swap_vert_rounded, size: 18),
                label: const Text('Swap'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _RouteStop(
          marker: _Marker.pickup,
          label: 'Pickup address',
          value: journey.pickup,
          onChanged: (p) =>
              controller.updateJourney((j) => j.copyWith(pickup: p)),
        ),
        for (var i = 0; i < journey.via.length; i++) ...[
          const SizedBox(height: 10),
          _RouteStop(
            marker: _Marker.via,
            label: 'Stop ${i + 1}',
            value: journey.via[i],
            onChanged: (p) =>
                controller.updateJourney((j) => j.setViaStop(i, p)),
            onRemove: () => controller.updateJourney((j) => j.removeViaStop(i)),
          ),
        ],
        const SizedBox(height: 10),
        _RouteStop(
          marker: _Marker.dropoff,
          label: 'Destination',
          value: journey.dropoff,
          onChanged: (p) =>
              controller.updateJourney((j) => j.copyWith(dropoff: p)),
        ),
        if (journey.canAddViaStop)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                final place = await showAddressSearchSheet(
                  context,
                  title: 'Add a stop',
                );
                if (place == null || !context.mounted) return;
                controller.updateJourney(
                  (j) =>
                      j.canAddViaStop ? j.copyWith(via: [...j.via, place]) : j,
                );
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                journey.via.isEmpty ? 'Add a stop' : 'Add another stop',
              ),
              style: TextButton.styleFrom(
                foregroundColor: colors.inkMuted,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          ),
      ],
    );
  }
}

enum _Marker { pickup, via, dropoff }

class _RouteStop extends StatelessWidget {
  const _RouteStop({
    required this.marker,
    required this.label,
    required this.value,
    required this.onChanged,
    this.onRemove,
  });
  final _Marker marker;
  final String label;
  final PlaceSelection value;
  final ValueChanged<PlaceSelection> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final selection = await showAddressSearchSheet(
              context,
              title: label,
              initial: value,
            );
            if (selection != null && context.mounted) onChanged(selection);
          },
          child: InputDecorator(
            isEmpty: value.isEmpty,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: colors.placeholder, fontSize: 14),
              floatingLabelStyle: TextStyle(
                color: colors.inkMuted,
                fontSize: 12,
              ),
              prefixIcon: Icon(
                marker == _Marker.pickup
                    ? Icons.my_location_rounded
                    : marker == _Marker.dropoff
                    ? Icons.location_on_outlined
                    : Icons.more_horiz_rounded,
                size: 21,
                color: colors.accent,
              ),
              suffixIcon: onRemove != null
                  ? IconButton(
                      tooltip: 'Remove $label',
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: colors.inkMuted,
                      ),
                      onPressed: onRemove,
                    )
                  : Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: colors.inkMuted,
                    ),
            ),
            child: Text(
              value.isEmpty ? '' : value.address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JourneyDateTimeField extends StatelessWidget {
  const _JourneyDateTimeField({
    required this.date,
    required this.time,
    required this.minimum,
    required this.title,
    required this.onChanged,
  });
  final DateTime? date;
  final TimeOfDay? time;
  final DateTime minimum;
  final String title;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = date == null
        ? null
        : DateTime(
            date!.year,
            date!.month,
            date!.day,
            time?.hour ?? 9,
            time?.minute ?? 0,
          );
    final complete = date != null && time != null;
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final value = await showJourneyDateTimeSheet(
              context,
              title: title,
              minimum: minimum,
              initial: initial,
            );
            if (value != null && context.mounted) onChanged(value);
          },
          child: InputDecorator(
            isEmpty: !complete,
            decoration: InputDecoration(
              labelText: title,
              labelStyle: TextStyle(color: colors.placeholder, fontSize: 14),
              floatingLabelStyle: TextStyle(
                color: colors.inkMuted,
                fontSize: 12,
              ),
              prefixIcon: Icon(
                Icons.calendar_month_outlined,
                size: 21,
                color: colors.accent,
              ),
              suffixIcon: Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: colors.inkMuted,
              ),
            ),
            child: Text(
              complete ? Formatting.journeyDateAndTime(initial!) : '',
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
