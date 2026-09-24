import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../driver_state.dart';
import '../widgets/driver_header.dart';

class DriverBookingsScreen extends ConsumerWidget {
  const DriverBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(driverControllerProvider);
    final filterIndex = state.bookingsFilterIndex;

    final filterLabels = ['Upcoming', 'Completed', 'Cancelled'];

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const DriverHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  Text(
                    'Bookings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Pills (Upcoming, Completed, Cancelled)
                  Row(
                    children: List.generate(filterLabels.length, (i) {
                      final isSelected = filterIndex == i;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            ref.read(driverControllerProvider.notifier).setBookingsFilter(i);
                          },
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.brand : colors.card,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isSelected ? AppTheme.brand : colors.inkFaint,
                              ),
                            ),
                            child: Text(
                              filterLabels[i],
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppTheme.midnight : colors.ink,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Bookings List Items
                  ...state.upcomingJobs.map((job) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.inkFaint),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.brand.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  job.type.contains('Airport')
                                      ? Icons.flight_takeoff_rounded
                                      : Icons.directions_car_outlined,
                                  size: 16,
                                  color: AppTheme.brandDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                job.type,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: colors.ink,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                job.pickupTime,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: colors.inkMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${job.pickupAddress} → ${job.destinationAddress}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${job.passengersCount} Passengers • ${job.reference}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '£${job.fare.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: colors.ink,
                                ),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.brand,
                                  foregroundColor: AppTheme.midnight,
                                  minimumSize: const Size(70, 32),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                onPressed: () {
                                  context.push('/driver/trip');
                                },
                                child: const Text(
                                  'View',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
