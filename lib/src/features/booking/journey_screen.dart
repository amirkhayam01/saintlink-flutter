import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/env.dart';
import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../domain/place.dart';
import '../../domain/vehicle_category.dart';
import '../../widgets/common.dart';
import '../../widgets/vehicle_image.dart';
import '../auth/auth_controller.dart';
import '../places/address_search_field.dart';
import 'booking_flow_controller.dart';
import 'journey_draft.dart';

/// Home: the brand, then the booking card, then the reasons to trust it.
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
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                _Hero(
                  signedIn: auth.isSignedIn,
                  firstName: auth.customer?.firstName,
                  onTrips: () => context.push('/trips'),
                  onSignIn: () => context.push('/sign-in'),
                ),
                // The card starts inside the hero and runs past it, which is
                // what makes the page read as one piece rather than a banner
                // stuck above a form.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 300, 16, 0),
                  child: _BookingCard(journey: journey, state: state, controller: controller),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          const SliverToBoxAdapter(child: _TrustRow()),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverToBoxAdapter(child: _FleetStrip(vehicles: state.vehicles)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
              child: Column(
                children: [
                  Text('Southampton, Hampshire and every UK airport and port.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                  if (Env.isDevelopmentBackend) ...[
                    const SizedBox(height: 8),
                    Text('Connected to ${Env.apiBaseUrl}', style: TextStyle(color: context.colors.inkMuted, fontSize: 11)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.signedIn, required this.firstName, required this.onTrips, required this.onSignIn});

  final bool signedIn;
  final String? firstName;
  final VoidCallback onTrips;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 400,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/brand/hero.webp', fit: BoxFit.cover, alignment: const Alignment(0.3, 0)),
          // Dark at the top for the logo, darker at the bottom so the card's
          // shadow and the headline sit on midnight rather than on the photo.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x99020617), Color(0x33020617), Color(0xE6020617), AppTheme.midnight],
                stops: [0, 0.35, 0.8, 1],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 12, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/brand/logo-dark.png', height: 30),
                    const Spacer(),
                    if (signedIn)
                      _HeroChip(icon: Icons.receipt_long_outlined, label: 'My trips', onTap: onTrips)
                    else
                      _HeroChip(icon: Icons.person_outline, label: 'Sign in', onTap: onSignIn),
                  ],
                ),
                const Spacer(),
                Text(
                  signedIn && firstName != null ? 'Welcome back, $firstName.' : 'Southampton transfers,\nhandled with care.',
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -0.6),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fixed prices, licensed drivers, and a car that is there when your flight is.',
                  style: TextStyle(color: Color(0xFFD4D4D8), fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.journey, required this.state, required this.controller});

  final JourneyDraft journey;
  final BookingFlowState state;
  final BookingFlowController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(24), boxShadow: colors.floatingShadow),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RouteEditor(journey: journey, controller: controller),
          const SizedBox(height: 16),
          _DateTimeRow(
            date: journey.pickupDate,
            time: journey.pickupTime,
            onDate: (d) => controller.updateJourney((j) => j.copyWith(pickupDate: d)),
            onTime: (t) => controller.updateJourney((j) => j.copyWith(pickupTime: t)),
          ),
          const SizedBox(height: 12),
          _ToggleRow(
            icon: Icons.swap_vert,
            label: 'Return journey',
            value: journey.isReturn,
            onChanged: (on) => controller.updateJourney((j) => on ? j.copyWith(isReturn: true) : j.withoutReturn()),
          ),
          if (journey.isReturn) ...[
            const SizedBox(height: 12),
            _DateTimeRow(
              date: journey.returnDate,
              time: journey.returnTime,
              firstDate: journey.pickupDate,
              onDate: (d) => controller.updateJourney((j) => j.copyWith(returnDate: d)),
              onTime: (t) => controller.updateJourney((j) => j.copyWith(returnTime: t)),
            ),
          ],
          const SizedBox(height: 12),
          _Tile(
            icon: Icons.people_outline,
            label: _travellersLabel(journey),
            onTap: () => _showTravellers(context, controller),
            trailing: Icon(Icons.expand_more, color: colors.inkMuted),
          ),
          if (journey.touchesAirport) ...[
            const SizedBox(height: 12),
            _FlightFields(
              flightNumber: journey.outboundFlightNumber,
              terminal: journey.outboundTerminal,
              onFlight: (v) => controller.updateJourney((j) => j.copyWith(outboundFlightNumber: v)),
              onTerminal: (v) => controller.updateJourney((j) => j.copyWith(outboundTerminal: v)),
            ),
          ],
          if (state.quoteError != null) ...[const SizedBox(height: 12), ErrorNotice(state.quoteError!)],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: journey.isQuotable && !state.isQuoting
                ? () async {
                    if (await controller.requestQuote() && context.mounted) context.push('/book/vehicle');
                  }
                : null,
            child: state.isQuoting ? const ButtonSpinner() : const Text('See prices'),
          ),
          const SizedBox(height: 10),
          Text('Fixed price. No account needed for a quote.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ],
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
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.inkFaint)),
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

/// A filled, tappable row inside the booking card.
class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.onTap, this.trailing, this.muted = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.inkFaint)),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colors.inkMuted),
              const SizedBox(width: 12),
              Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: muted ? FontWeight.w400 : FontWeight.w600, color: muted ? colors.inkMuted : colors.ink))),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.icon, required this.label, required this.value, required this.onChanged});

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Tile(
      icon: icon,
      label: label,
      onTap: () => onChanged(!value),
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeTrackColor: AppTheme.brand, activeThumbColor: AppTheme.midnight),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({required this.date, required this.time, required this.onDate, required this.onTime, this.firstDate});

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
          child: _Tile(
            icon: Icons.calendar_today_outlined,
            label: date == null ? 'Date' : Formatting.date(date!),
            muted: date == null,
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
          child: _Tile(
            icon: Icons.schedule_outlined,
            label: time == null ? 'Time' : MaterialLocalizations.of(context).formatTimeOfDay(time!, alwaysUse24HourFormat: true),
            muted: time == null,
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

class _TrustRow extends StatelessWidget {
  const _TrustRow();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.verified_outlined, 'Fixed price', 'Quoted up front,\nnothing added'),
      (Icons.flight_land, 'Flight tracked', 'We move the pickup\nif your flight does'),
      (Icons.badge_outlined, 'Licensed drivers', 'Meet & greet at\nairports and ports'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (final (icon, title, body) in items)
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppTheme.brand.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: AppTheme.brandDark, size: 22),
                  ),
                  const SizedBox(height: 10),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(body, textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkMuted, fontSize: 12, height: 1.3)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FleetStrip extends StatelessWidget {
  const _FleetStrip({required this.vehicles});

  final List<VehicleCategory> vehicles;

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Our fleet', style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 196,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: vehicles.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final v = vehicles[index];

              return Container(
                width: 220,
                decoration: BoxDecoration(color: context.colors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: context.colors.inkFaint)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 118, width: double.infinity, child: VehicleImage(v.slug)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 15, color: context.colors.inkMuted),
                              Text(' ${v.passengerCapacity}', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(width: 10),
                              Icon(Icons.luggage_outlined, size: 15, color: context.colors.inkMuted),
                              Text(' ${v.luggageCapacity}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
