import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../domain/place.dart';
import '../../widgets/common.dart';
import '../../widgets/tiles.dart';
import '../../widgets/inner_screen_header.dart';
import '../../widgets/route_timeline.dart';
import '../places/address_search_field.dart';
import '../places/current_location.dart';
import 'booking_flow_controller.dart';
import 'booking_screen_header.dart';
import 'google_journey_map.dart';
import 'journey_draft.dart';
import 'journey_date_time_sheet.dart';

/// The booking form in two stages over a map: the route, then only what the price depends on.
/// Fields mirror the website's search widget; the server validates both the same way.
class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

enum _Stage { route, when }

class _JourneyScreenState extends ConsumerState<JourneyScreen> {
  // Always the route first, even when preset: the customer sees it on the map before anything else.
  _Stage _stage = _Stage.route;

  @override
  void initState() {
    super.initState();
    _prefillPickup();
  }

  /// The launch location as the pickup, unless one is already set or gets
  /// set first.
  Future<void> _prefillPickup() async {
    if (!ref.read(bookingFlowProvider).journey.pickup.isEmpty) return;
    final place = await ref.read(currentPlaceProvider.future);
    if (!mounted || place == null) return;
    if (!ref.read(bookingFlowProvider).journey.pickup.isEmpty) return;
    ref
        .read(bookingFlowProvider.notifier)
        .updateJourney((j) => j.copyWith(pickup: place));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingFlowProvider);
    final controller = ref.read(bookingFlowProvider.notifier);
    final journey = state.journey;
    final colors = context.colors;
    final onRoute = _stage == _Stage.route;

    return Scaffold(
      appBar: BookingScreenHeader(
        journey: journey,
        curvedEdge: false,
        title: onRoute ? 'Plan your journey' : 'When are you travelling?',
        // From the second stage, back is back to the route, not out of the form.
        onBack: onRoute
            ? () => context.pop()
            : () => setState(() => _stage = _Stage.route),
        actions: [
          if (!journey.pickup.isEmpty ||
              !journey.dropoff.isEmpty ||
              journey.pickupDate != null)
            IconButton(
              tooltip: 'Clear journey',
              onPressed: () {
                controller.reset();
                setState(() => _stage = _Stage.route);
              },
              icon: const Icon(Icons.restart_alt_rounded),
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          GoogleJourneyMap(
            journey: journey,
            interactive: true,
            regionWhenEmpty: true,
          ),
          DraggableScrollableSheet(
            initialChildSize: onRoute ? 0.56 : 0.72,
            minChildSize: 0.4,
            maxChildSize: 0.94,
            snap: true,
            builder: (context, scroll) => Material(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  const _DragHandle(),
                  Expanded(
                    child: ListView(
                      controller: scroll,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                      children: [
                        const BookingProgress(step: 0),
                        const SizedBox(height: 20),
                        if (onRoute)
                          _RouteEditor(journey: journey, controller: controller)
                        else
                          _WhenAndWho(
                            journey: journey,
                            controller: controller,
                            onEditRoute: () =>
                                setState(() => _stage = _Stage.route),
                          ),
                        if (!onRoute && state.quoteError != null) ...[
                          const SizedBox(height: 16),
                          ErrorNotice(state.quoteError!),
                        ],
                      ],
                    ),
                  ),
                  BottomAction(
                    verticalPadding: 8,
                    child: onRoute
                        ? FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: journey.hasRoute
                                ? () => setState(() => _stage = _Stage.when)
                                : null,
                            child: const Text('Continue'),
                          )
                        : FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: journey.isQuotable && !state.isQuoting
                                ? () async {
                                    if (await controller.requestQuote() &&
                                        context.mounted) {
                                      context.push('/book/vehicle');
                                    }
                                  }
                                : null,
                            child: state.isQuoting
                                ? const ButtonSpinner()
                                : const Text('See prices'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The pill that says "this slides".
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 6),
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.colors.inkFaint,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

/// The second stage: the route as a line to check, then what the price
/// depends on.
class _WhenAndWho extends StatelessWidget {
  const _WhenAndWho({
    required this.journey,
    required this.controller,
    required this.onEditRoute,
  });

  final JourneyDraft journey;
  final BookingFlowController controller;
  final VoidCallback onEditRoute;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            child: Row(
              children: [
                Expanded(
                  child: RouteTimeline(
                    dense: true,
                    points: [
                      RoutePoint(address: journey.pickup.address),
                      for (final stop in journey.via)
                        if (!stop.isEmpty) RoutePoint(address: stop.address),
                      RoutePoint(address: journey.dropoff.address),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onEditRoute,
                  style: TextButton.styleFrom(foregroundColor: colors.accent),
                  child: const Text('Edit'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
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
          activeTrackColor: colors.accent.withValues(alpha: 0.3),
          activeThumbColor: colors.accent,
          value: journey.isReturn,
          onChanged: (value) => controller.updateJourney(
            (j) => value ? j.copyWith(isReturn: true) : j.withoutReturn(),
          ),
        ),
        if (journey.isReturn)
          _ReturnCard(journey: journey, controller: controller),
        const SizedBox(height: 24),
        CountStepper(
          label: 'Passengers',
          value: journey.passengerCount,
          min: 1,
          max: 8,
          onChanged: (v) =>
              controller.updateJourney((j) => j.copyWith(passengerCount: v)),
        ),
        const SizedBox(height: 8),
        CountStepper(
          label: 'Large suitcases',
          value: journey.luggageCount,
          min: 0,
          max: 8,
          onChanged: (v) =>
              controller.updateJourney((j) => j.copyWith(luggageCount: v)),
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(label),
        Semantics(
          button: true,
          label: label,
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
                  allowCurrentLocation: marker == _Marker.pickup,
                );
                if (selection != null && context.mounted) onChanged(selection);
              },
              child: InputDecorator(
                isEmpty: value.isEmpty,
                decoration: InputDecoration(
                  hintText: switch (marker) {
                    _Marker.pickup => 'Where shall we collect you?',
                    _Marker.dropoff => 'Where are you going?',
                    _Marker.via => 'Somewhere on the way',
                  },
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
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(title),
        Semantics(
          button: true,
          label: title,
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
                  hintText: 'Choose a date and time',
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
        ),
      ],
    );
  }
}
