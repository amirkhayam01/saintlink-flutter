import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../driver_models.dart';
import '../driver_state.dart';
import '../widgets/driver_header.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  void _showNewBookingSheet(BuildContext context, WidgetRef ref, DriverJob job) {
    final colors = context.colors;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: colors.card,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.inkFaint,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Booking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.ink,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.brand.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        job.type,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Route details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pickup', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                          const SizedBox(height: 1),
                          Text(job.pickupAddress, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.ink)),
                          Text(job.pickupDetail, style: TextStyle(fontSize: 11.5, color: colors.inkMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.5, top: 4, bottom: 4),
                  child: Container(width: 1.5, height: 20, color: colors.inkFaint),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppTheme.brandDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Destination', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                          const SizedBox(height: 1),
                          Text(job.destinationAddress, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.ink)),
                          Text(job.destinationDetail, style: TextStyle(fontSize: 11.5, color: colors.inkMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Date, Time & Flight
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.inkFaint),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 16, color: colors.inkMuted),
                          const SizedBox(width: 10),
                          Text('Pickup Date & Time:', style: TextStyle(fontSize: 12, color: colors.inkMuted)),
                          const Spacer(),
                          Text(job.pickupTime, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: colors.ink)),
                        ],
                      ),
                      if (job.flightNumber != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.flight_takeoff_rounded, size: 16, color: colors.inkMuted),
                            const SizedBox(width: 10),
                            Text('Flight Information:', style: TextStyle(fontSize: 12, color: colors.inkMuted)),
                            const Spacer(),
                            Text(job.flightNumber!, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: colors.ink)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Passenger Details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.inkFaint),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.brand,
                        child: Text(
                          job.passengerName.isNotEmpty ? job.passengerName[0] : 'P',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.midnight),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.passengerName, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colors.ink)),
                            Text('${job.passengersCount} Passengers • ${job.luggageCount} Bags', style: TextStyle(fontSize: 11.5, color: colors.inkMuted)),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.phone_outlined, size: 14),
                        label: const Text('Call', style: TextStyle(fontSize: 11.5)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.ink,
                          side: BorderSide(color: colors.inkFaint),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: const Size(60, 32),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Action Buttons: Decline & Accept Job
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.ink,
                          side: BorderSide(color: colors.inkFaint),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('✕ Decline', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.brand,
                          foregroundColor: AppTheme.midnight,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          context.push('/driver/trip');
                        },
                        child: const Text('✓ Accept Job', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(driverControllerProvider);
    final isOnline = state.isOnline;
    final job = state.activeJob;

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
                  // Greeting & Subtitle
                  Text(
                    'Good morning,',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.inkMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'John Smith 👋',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Online / Offline Status Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.inkFaint),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isOnline ? const Color(0xFF10B981) : colors.inkMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.ink,
                          ),
                        ),
                        const Spacer(),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch.adaptive(
                            value: isOnline,
                            activeTrackColor: const Color(0xFF10B981),
                            onChanged: (val) {
                              ref.read(driverControllerProvider.notifier).toggleOnline(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2 KPI Metric Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
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
                                  Icon(Icons.account_balance_wallet_outlined, size: 16, color: colors.inkMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Today's Earnings",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: colors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '£86.40',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: colors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
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
                                  Icon(Icons.calendar_today_outlined, size: 16, color: colors.inkMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Completed Trips',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: colors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '6',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: colors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Upcoming Booking Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colors.ink,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          ref.read(driverControllerProvider.notifier).setNavIndex(1);
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Upcoming Booking Card
                  InkWell(
                    onTap: () => _showNewBookingSheet(context, ref, job),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.inkFaint),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(14),
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
                                        Icons.flight_takeoff_rounded,
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
                                const SizedBox(height: 12),
                                // Route
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 15, color: const Color(0xFF10B981)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        job.pickupAddress,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12.5, color: colors.ink, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded, size: 15, color: AppTheme.brandDark),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        job.destinationAddress,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12.5, color: colors.ink, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.people_outline_rounded, size: 14, color: colors.inkMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${job.passengersCount} Passengers',
                                      style: TextStyle(fontSize: 11.5, color: colors.inkMuted),
                                    ),
                                    const SizedBox(width: 14),
                                    Icon(Icons.directions_car_outlined, size: 14, color: colors.inkMuted),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        job.vehicleInfo,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 11.5, color: colors.inkMuted),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Highlight Banner at Bottom of Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.midnight,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 16, color: AppTheme.brand),
                                    SizedBox(width: 8),
                                    Text(
                                      'Next Trip in 1h 20m',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.brand),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
