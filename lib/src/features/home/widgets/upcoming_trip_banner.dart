import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting.dart';
import '../../../core/theme.dart';
import '../../auth/auth_controller.dart';
import '../../trips/trips_controller.dart';

/// The customer's next booking as a card, or nothing at all.
///
/// Because it is often absent, it owns the gap beneath it: the column it sits
/// in should not leave one, or the sections below would drift apart when
/// there is no trip.
class UpcomingTripBanner extends ConsumerWidget {
  const UpcomingTripBanner({
    super.key,
    required this.auth,
    this.spacingBelow = 24,
  });

  final AuthState auth;
  final double spacingBelow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    if (!auth.isSignedIn) {
      return const SizedBox.shrink();
    }

    final tripsAsync = ref.watch(tripsProvider);
    return tripsAsync.maybeWhen(
      data: (tripsState) {
        final upcoming = tripsState.upcoming;
        if (upcoming.isEmpty) {
          return const SizedBox.shrink();
        }

        final nextTrip = upcoming.first;
        final from = nextTrip.pickupAddress ?? 'Southampton';
        final to = nextTrip.dropoffAddress ?? 'Destination';
        final flight = nextTrip.legs.isNotEmpty
            ? nextTrip.legs.first.flight
            : null;
        final isAirport =
            (flight != null) ||
            to.toLowerCase().contains('airport') ||
            from.toLowerCase().contains('airport');

        return Padding(
          padding: EdgeInsets.only(bottom: spacingBelow),
          child: Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.inkFaint),
              boxShadow: colors.floatingShadow,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.tint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Wrap(
                        spacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            isAirport
                                ? Icons.flight_takeoff_rounded
                                : Icons.calendar_today_rounded,
                            size: 13,
                            color: colors.accent,
                          ),
                          Text(
                            'UPCOMING TRANSFER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: colors.accent,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (flight != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${flight.number} · Tracked',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.success,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$from → $to',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: colors.inkMuted,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        nextTrip.pickupAt != null
                            ? '${Formatting.date(nextTrip.pickupAt!)} at ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(nextTrip.pickupAt!), alwaysUse24HourFormat: true)}'
                            : 'Scheduled transfer',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colors.inkMuted,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: colors.accent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () =>
                          context.push('/trips/${nextTrip.reference}'),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Details'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 13),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
