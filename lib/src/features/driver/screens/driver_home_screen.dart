import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../widgets/hero_banner.dart';
import '../driver_state.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  static String get greetingText {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(driverControllerProvider);
    final isOnline = state.isOnline;
    final job = state.activeJob;

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: HeroPage(
              hero: HeroBanner(
                image: const AssetImage('assets/brand/hero.webp'),
                height: 240,
                bottomInset: OverlapSheet.overlap,
                title: '$greetingText, John! 👋',
                subtitle: isOnline
                    ? 'You are online and ready to receive journey requests.'
                    : 'You are currently offline. Toggle online to start your shift.',
                leading: Image.asset(
                  'assets/brand/logo-dark.png',
                  height: 30,
                ),
                actions: [
                  _DriverAccountChip(
                    onTap: () {
                      ref
                          .read(driverControllerProvider.notifier)
                          .setNavIndex(3);
                    },
                  ),
                ],
              ),
              sheet: OverlapSheet(
                padding: const EdgeInsets.only(top: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Online / Offline Status Toggle Banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isOnline
                                ? const Color(0xFF10B981).withValues(alpha: 0.35)
                                : colors.inkFaint,
                          ),
                          boxShadow: isOnline
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: isOnline
                                    ? const Color(0xFF10B981)
                                    : colors.inkMuted,
                                shape: BoxShape.circle,
                                boxShadow: isOnline
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.5),
                                          blurRadius: 6,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isOnline ? 'Online · Accepting Trips' : 'Offline',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: colors.ink,
                                    ),
                                  ),
                                  Text(
                                    isOnline
                                        ? 'Southampton & Airport coverage'
                                        : 'Tap switch to go online',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: colors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Transform.scale(
                              scale: 0.85,
                              child: Switch.adaptive(
                                value: isOnline,
                                activeTrackColor: const Color(0xFF10B981),
                                onChanged: (val) {
                                  ref
                                      .read(driverControllerProvider.notifier)
                                      .toggleOnline(val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2x2 Metric Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: _DriverMetricCard(
                              icon: Icons.account_balance_wallet_outlined,
                              iconColor: const Color(0xFF10B981),
                              title: "Today's Earnings",
                              value: '£86.40',
                              changeText: '+12% vs yesterday',
                              changeColor: const Color(0xFF10B981),
                              arrowUp: true,
                              onTap: () {
                                ref
                                    .read(driverControllerProvider.notifier)
                                    .setNavIndex(2);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DriverMetricCard(
                              icon: Icons.directions_car_outlined,
                              iconColor: const Color(0xFF3B82F6),
                              title: 'Trips Completed',
                              value: '6',
                              changeText: 'Target: 8 trips',
                              changeColor: const Color(0xFF3B82F6),
                              onTap: () {
                                ref
                                    .read(driverControllerProvider.notifier)
                                    .setNavIndex(1);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DriverMetricCard(
                              icon: Icons.star_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              title: 'Driver Rating',
                              value: '4.8 ★',
                              changeText: '128 total reviews',
                              changeColor: colors.inkMuted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DriverMetricCard(
                              icon: Icons.check_circle_outline_rounded,
                              iconColor: const Color(0xFF10B981),
                              title: 'Acceptance Rate',
                              value: '98%',
                              changeText: 'Top tier driver',
                              changeColor: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Upcoming / Current Booking Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Booking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: colors.ink,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              ref
                                  .read(driverControllerProvider.notifier)
                                  .setNavIndex(1);
                            },
                            child: const Text(
                              'View All Bookings',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Upcoming Booking Hero Card
                      InkWell(
                        onTap: () => context.push('/driver/trip'),
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
                                          child: const Icon(
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
                                    // Route details
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 15,
                                          color: Color(0xFF10B981),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            job.pickupAddress,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: colors.ink,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          size: 15,
                                          color: AppTheme.brandDark,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            job.destinationAddress,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: colors.ink,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.people_outline_rounded,
                                          size: 14,
                                          color: colors.inkMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${job.passengersCount} Passengers',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: colors.inkMuted,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Icon(
                                          Icons.directions_car_outlined,
                                          size: 14,
                                          color: colors.inkMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            job.vehicleInfo,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: colors.inkMuted,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '£${job.fare.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: colors.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Highlight Banner at Bottom of Card
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppTheme.midnight,
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(15),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.navigation_rounded,
                                          size: 16,
                                          color: AppTheme.brand,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Next Trip in 1h 20m · Tap for Navigation',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: AppTheme.brand,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Quick Action Strip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.inkFaint),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.brand.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.map_outlined,
                                color: AppTheme.brandDark,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Live Navigation',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: colors.ink,
                                    ),
                                  ),
                                  Text(
                                    'Open GPS route & turn-by-turn guidance',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: colors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.brand,
                                foregroundColor: AppTheme.midnight,
                                minimumSize: const Size(60, 32),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              onPressed: () {
                                context.push('/driver/trip');
                              },
                              child: const Text(
                                'Open',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 28 + MediaQuery.paddingOf(context).bottom,
            ),
          ),
        ],
      ),
    );
  }
}

/// Driver account chip styled like the user's HomeAccountChip.
class _DriverAccountChip extends StatelessWidget {
  const _DriverAccountChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.brand,
                child: const Text(
                  'JS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.midnight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'John Smith',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverMetricCard extends StatelessWidget {
  const _DriverMetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.changeText,
    required this.changeColor,
    this.arrowUp,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String changeText;
  final Color changeColor;
  final bool? arrowUp;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colors.inkMuted,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (arrowUp != null)
                    Icon(
                      arrowUp!
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 11,
                      color: changeColor,
                    ),
                  if (arrowUp != null) const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      changeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: changeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
