import 'package:flutter/material.dart';

import '../core/formatting.dart';
import '../core/theme.dart';
import '../domain/booking.dart';
import 'common.dart';
import 'list_row.dart';
import 'route_timeline.dart';
import 'vehicle_image.dart';

/// A booking laid out as journey, vehicle and fare: the same three cards on
/// the confirmation and, weeks later, on the trip.
class BookingSummary extends StatelessWidget {
  const BookingSummary({
    super.key,
    required this.booking,
    this.paidOverride = false,
  });

  final Booking booking;

  /// True right after an in-app payment, before the server has caught up.
  final bool paidOverride;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Journey'),
        const SizedBox(height: 8),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < booking.legs.length; i++) ...[
                if (i > 0) const ListRowDivider(),
                _LegSection(
                  leg: booking.legs[i],
                  showDirection: booking.isReturn,
                ),
              ],
            ],
          ),
        ),
        if (booking.vehicle != null) ...[
          const SizedBox(height: 20),
          const SectionTitle('Vehicle'),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: _VehicleRow(booking: booking),
          ),
        ],
        const SizedBox(height: 20),
        const SectionTitle('Fare'),
        const SizedBox(height: 8),
        Card(
          clipBehavior: Clip.antiAlias,
          child: _FareBreakdown(booking: booking, paidOverride: paidOverride),
        ),
      ],
    );
  }
}

/// One leg: when, the route, and the facts about the pickup.
class _LegSection extends StatelessWidget {
  const _LegSection({required this.leg, required this.showDirection});

  final BookingLeg leg;
  final bool showDirection;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final when = leg.pickupAt;
    final facts = [
      if (leg.flight != null)
        (
          Icons.flight_takeoff_rounded,
          [
            leg.flight!.number,
            if (leg.flight!.terminal != null) leg.flight!.terminal!,
            if (leg.flight!.status != null) leg.flight!.status!,
          ].join(' · '),
        ),
      if (leg.meetAndGreet) (Icons.waving_hand_outlined, 'Meet & greet'),
      if (leg.includedWaitingMinutes > 0)
        (
          Icons.hourglass_bottom_rounded,
          '${leg.includedWaitingMinutes} min waiting included',
        ),
      if (leg.estimatedDurationMinutes != null)
        (
          Icons.schedule_rounded,
          [
            Formatting.duration(leg.estimatedDurationMinutes!),
            if (leg.distanceMiles != null) Formatting.miles(leg.distanceMiles!),
          ].join(' · '),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                showDirection && leg.isReturnLeg
                    ? Icons.keyboard_return_rounded
                    : Icons.calendar_today_rounded,
                size: 16,
                color: colors.accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  [
                    if (showDirection) leg.isReturnLeg ? 'Return' : 'Outward',
                    if (when != null)
                      '${Formatting.date(when)} · ${Formatting.time(when)}',
                  ].join(' · '),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                ),
              ),
            ],
          ),
          if (leg.pickupWasAdjusted)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 2),
              child: Text(
                'Moved from ${Formatting.time(leg.requestedPickupAt!)} to '
                'match your flight',
                style: TextStyle(color: colors.accent, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          RouteTimeline(
            dense: true,
            points: [
              RoutePoint(label: 'PICKUP', address: leg.pickupAddress),
              for (final stop in leg.viaStops)
                RoutePoint(label: 'STOP', address: stop.address),
              RoutePoint(label: 'DESTINATION', address: leg.dropoffAddress),
            ],
          ),
          if (facts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [for (final (icon, text) in facts) _Fact(icon, text)],
            ),
          ],
        ],
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  const _VehicleRow({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final leg = booking.legs.isEmpty ? null : booking.legs.first;
    final parts = [
      if (leg != null)
        '${leg.passengerCount} passenger${leg.passengerCount == 1 ? '' : 's'}',
      if (leg != null && leg.largeLuggageCount > 0)
        '${leg.largeLuggageCount} large bag${leg.largeLuggageCount == 1 ? '' : 's'}',
      if (leg?.serviceType != null) leg!.serviceType!,
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 88,
              height: 60,
              child: VehicleImage(vehicleSlugFor(booking.vehicle!)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.vehicle!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                ),
                if (parts.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    parts.join(' · '),
                    style: TextStyle(fontSize: 13, color: colors.inkMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FareBreakdown extends StatelessWidget {
  const _FareBreakdown({required this.booking, required this.paidOverride});

  final Booking booking;
  final bool paidOverride;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: Column(
        children: [
          for (final item in booking.fareItems)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(color: colors.inkMuted),
                    ),
                  ),
                  Text(
                    Formatting.money(item.amount, booking.currency),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                  ),
                ],
              ),
            ),
          if (booking.fareItems.isNotEmpty)
            Divider(height: 18, color: colors.inkFaint),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                ),
              ),
              StatusChip(
                label: paidOverride ? 'Paid' : booking.paymentStatusLabel,
                status: paidOverride ? 'paid' : booking.paymentStatus,
              ),
              const SizedBox(width: 12),
              Text(
                Formatting.money(booking.totalAmount, booking.currency),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: colors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.inkFaint),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.inkMuted),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 12.5, color: colors.inkMuted)),
        ],
      ),
    );
  }
}
