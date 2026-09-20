import 'package:flutter/material.dart';

import '../core/formatting.dart';
import '../core/theme.dart';
import '../domain/booking.dart';
import 'common.dart';
import 'route_timeline.dart';
import 'vehicle_image.dart';

/// A booking drawn as a ticket, the same on the confirmation and weeks later on the trip.
class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.booking,
    this.headline,
    this.paidOverride = false,
  });

  final Booking booking;

  /// Replaces the status label in the stub, e.g. "Thanks — we have your booking".
  final String? headline;

  /// True right after an in-app payment, before the server has caught up.
  final bool paidOverride;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final paid = paidOverride || booking.isPaid;
    final legs = booking.legs;
    final outbound = legs.isEmpty ? null : legs.first;
    final returnLeg = legs.length > 1 ? legs[1] : null;
    final slug = booking.vehicle == null ? null : _slugFor(booking.vehicle!);

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: colors.floatingShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stub
          Container(
            color: AppTheme.brand,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (headline ?? booking.statusLabel).toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.midnight,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        booking.reference,
                        style: const TextStyle(
                          color: AppTheme.midnight,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.midnight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    paid ? Icons.verified : Icons.check,
                    color: AppTheme.brand,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          _Perforation(colors: colors),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RouteTimeline(
                  points: [
                    if (outbound != null) ...[
                      RoutePoint(
                        address: outbound.pickupAddress,
                        label: outbound.pickupAt == null
                            ? 'Pickup'
                            : Formatting.dateAndTime(outbound.pickupAt!),
                        detail: outbound.flight == null
                            ? null
                            : 'Flight ${outbound.flight!.number}${outbound.flight!.terminal == null ? '' : ' · ${outbound.flight!.terminal}'}',
                      ),
                      for (final stop in outbound.viaStops)
                        RoutePoint(address: stop.address, label: 'Stop'),
                      RoutePoint(
                        address: outbound.dropoffAddress,
                        label: returnLeg?.pickupAt == null
                            ? 'Destination'
                            : 'Return ${Formatting.dateAndTime(returnLeg!.pickupAt!)}',
                      ),
                    ] else ...[
                      RoutePoint(
                        address: booking.pickupAddress ?? '',
                        label: booking.pickupAt == null
                            ? 'Pickup'
                            : Formatting.dateAndTime(booking.pickupAt!),
                      ),
                      RoutePoint(
                        address: booking.dropoffAddress ?? '',
                        label: 'Destination',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: colors.inkFaint),
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (slug != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 64,
                          height: 44,
                          child: VehicleImage(slug),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.vehicle ?? 'Vehicle to be confirmed',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            [
                              if (outbound != null)
                                '${outbound.passengerCount} passenger${outbound.passengerCount == 1 ? '' : 's'}',
                              if (booking.isReturn) 'return',
                              if (outbound?.meetAndGreet == true)
                                'meet & greet',
                            ].join(' · '),
                            style: TextStyle(
                              color: colors.inkMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatting.money(
                            booking.totalAmount,
                            booking.currency,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            letterSpacing: -0.3,
                          ),
                        ),
                        StatusChip(
                          label: paid ? 'Paid' : booking.paymentStatusLabel,
                          status: paid ? 'confirmed' : 'pending',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bookings carry the vehicle's display name; the photo is found by its slug form.
  String _slugFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('minibus')) return 'minibus-8';
    if (lower.contains('mpv')) return 'mpv-6';
    if (lower.contains('executive')) return 'executive-saloon';
    if (lower.contains('estate')) return 'estate-car';

    return 'saloon-car';
  }
}

/// The torn edge between stub and ticket: a dashed line with a half-circle
/// notch at each side, cut out of the card so the ground shows through.
class _Perforation extends StatelessWidget {
  const _Perforation({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: colors.card)),
          Positioned(left: -12, top: 0, child: _Notch(colors.surface)),
          Positioned(right: -12, top: 0, child: _Notch(colors.surface)),
          Positioned(
            left: 24,
            right: 24,
            top: 11,
            child: CustomPaint(
              size: const Size(double.infinity, 2),
              painter: _DashPainter(colors.inkFaint),
            ),
          ),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (var x = 0.0; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, 1), Offset(x + 5, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
