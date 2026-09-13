import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../core/theme_controller.dart';
import '../../domain/place.dart';
import '../../domain/vehicle_category.dart';
import '../../widgets/vehicle_image.dart';
import '../auth/auth_controller.dart';
import '../booking/booking_flow_controller.dart';
import '../trips/trips_controller.dart';

/// Redesigned production-grade Home Screen for Saints Link.
///
/// Executive chauffeur mobile experience defaulting to light mode.
/// Top bar with side drawer trigger, authentic brand logo, light/dark theme switch,
/// and profile or sign-in chip.
/// Side navigation drawer with full branding, account summary, navigation links,
/// and theme switcher.
/// Personalized greeting header ("Good morning, {name}").
/// Seamless upcoming trip status card or Southampton concierge welcome banner.
/// Instant search launcher with popular hub shortcuts.
/// Executive services grid, popular fixed fares, and fleet showcase.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static String get greetingText {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final auth = ref.watch(authControllerProvider);
    final bookingState = ref.watch(bookingFlowProvider);
    final bookingController = ref.read(bookingFlowProvider.notifier);
    final firstName = auth.customer?.firstName;

    return Scaffold(
      backgroundColor: colors.surface,
      drawer: const _AppDrawer(),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _HomeTopBar(
                auth: auth,
                onToggleTheme: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                onProfile: () => context.push('/profile'),
                onSignIn: () => context.push('/sign-in'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greetingText${firstName != null && firstName.isNotEmpty ? ', $firstName' : ''}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: colors.ink,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Where would you like to travel today?',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.inkMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _UpcomingTripBanner(auth: auth),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _SearchLauncher(
                  onTap: () => context.go('/book'),
                  onSelectHub: (name, address) {
                    bookingController.updateJourney((j) => j.copyWith(
                          pickup: j.pickup.isEmpty ? const PlaceSelection(address: 'Southampton, UK') : j.pickup,
                          dropoff: PlaceSelection(address: address),
                        ));
                    context.go('/book');
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _ServicesGrid(
                  onSelectService: (serviceName, defaultDropoff) {
                    if (defaultDropoff != null) {
                      bookingController.updateJourney((j) => j.copyWith(
                            pickup: j.pickup.isEmpty ? const PlaceSelection(address: 'Southampton, UK') : j.pickup,
                            dropoff: PlaceSelection(address: defaultDropoff),
                          ));
                    }
                    context.go('/book');
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: _PopularFaresSection(
                onSelectFare: (from, to) {
                  bookingController.updateJourney((j) => j.copyWith(
                        pickup: PlaceSelection(address: from),
                        dropoff: PlaceSelection(address: to),
                      ));
                  context.go('/book');
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: _FleetShowcaseSection(
                vehicles: bookingState.vehicles,
                onSelectVehicle: (v) {
                  bookingController.updateJourney((j) => j.copyWith(
                        vehicleCategorySlug: v.slug,
                      ));
                  context.go('/book');
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            const SliverToBoxAdapter(child: _TrustStrip()),
            const SliverToBoxAdapter(child: SizedBox(height: 36)),
          ],
        ),
      ),
    );
  }
}

/// Top bar with side drawer trigger, authentic brand logo, theme switcher,
/// and profile/sign-in action.
class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.auth,
    required this.onToggleTheme,
    required this.onProfile,
    required this.onSignIn,
  });

  final AuthState auth;
  final VoidCallback onToggleTheme;
  final VoidCallback onProfile;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = auth.customer?.firstName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          // Drawer menu icon button
          Builder(
            builder: (ctx) => Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.inkFaint),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                iconSize: 22,
                padding: EdgeInsets.zero,
                tooltip: 'Open menu',
                icon: Icon(Icons.menu_rounded, color: colors.ink),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ),
          const Spacer(),
          // Light/Dark mode switcher button
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: colors.card,
              shape: BoxShape.circle,
              border: Border.all(color: colors.inkFaint),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              iconSize: 20,
              padding: EdgeInsets.zero,
              tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? AppTheme.brand : colors.ink,
              ),
              onPressed: onToggleTheme,
            ),
          ),
          // Profile avatar or sign-in chip
          if (auth.isSignedIn)
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colors.inkFaint),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppTheme.brand,
                      child: Text(
                        (firstName != null && firstName.isNotEmpty) ? firstName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.midnight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      firstName ?? 'Profile',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onSignIn,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.brand : AppTheme.midnight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: isDark ? AppTheme.midnight : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.midnight : Colors.white,
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

/// Side navigation drawer housing brand logo, user account details,
/// quick navigation links, and theme toggle switch.
class _AppDrawer extends ConsumerWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = ref.watch(authControllerProvider);
    final name = auth.customer?.name ?? 'Guest User';
    final email = auth.customer?.email ?? 'Sign in for fast booking';

    return Drawer(
      backgroundColor: colors.card,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    isDark ? 'assets/brand/logo-dark.png' : 'assets/brand/logo-light.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppTheme.brand,
                        child: Text(
                          auth.customer?.firstName.isNotEmpty == true
                              ? auth.customer!.firstName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.midnight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              email,
                              style: TextStyle(fontSize: 13, color: colors.inkMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: colors.inkFaint),
            ListTile(
              leading: Icon(Icons.home_outlined, color: colors.ink),
              title: Text('Home', style: TextStyle(color: colors.ink, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/');
              },
            ),
            ListTile(
              leading: Icon(Icons.commute_outlined, color: colors.ink),
              title: Text('Book a Transfer', style: TextStyle(color: colors.ink, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/book');
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt_long_outlined, color: colors.ink),
              title: Text('My Trips', style: TextStyle(color: colors.ink, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/trips');
              },
            ),
            ListTile(
              leading: Icon(Icons.person_outline_rounded, color: colors.ink),
              title: Text('Profile & Settings', style: TextStyle(color: colors.ink, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/profile');
              },
            ),
            const Spacer(),
            Divider(color: colors.inkFaint),
            // Theme toggle inside the drawer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.inkFaint),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: isDark ? AppTheme.brand : colors.ink,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isDark ? 'Dark Mode' : 'Light Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: colors.ink,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: isDark,
                      activeTrackColor: AppTheme.brand,
                      activeThumbColor: AppTheme.midnight,
                      onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                'Saints Link v0.1.0 · Southampton, UK',
                style: TextStyle(fontSize: 11, color: colors.inkMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dynamic Upcoming Booking snapshot if user has an active ride,
/// or Southampton Concierge welcome banner.
class _UpcomingTripBanner extends ConsumerWidget {
  const _UpcomingTripBanner({required this.auth});

  final AuthState auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        final flight = nextTrip.legs.isNotEmpty ? nextTrip.legs.first.flight : null;
        final isAirport = (flight != null) ||
            to.toLowerCase().contains('airport') ||
            from.toLowerCase().contains('airport');

        return Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: colors.floatingShadow,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.brand.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAirport ? Icons.flight_takeoff_rounded : Icons.calendar_today_rounded,
                          size: 13,
                          color: AppTheme.brandDark,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'UPCOMING TRANSFER',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.brandDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (flight != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                  Icon(Icons.schedule_rounded, size: 15, color: colors.inkMuted),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => context.push('/trips/${nextTrip.reference}'),
                    child: const Row(
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
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// Instant "Where can we take you?" search bar and popular UK destination chips.
class _SearchLauncher extends StatelessWidget {
  const _SearchLauncher({required this.onTap, required this.onSelectHub});

  final VoidCallback onTap;
  final void Function(String name, String address) onSelectHub;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hubs = [
      (label: 'Heathrow (LHR)', icon: Icons.flight_takeoff_rounded, address: 'London Heathrow Airport (LHR)'),
      (label: 'Cruise Terminal', icon: Icons.directions_boat_rounded, address: 'Southampton Cruise Terminals'),
      (label: 'Gatwick (LGW)', icon: Icons.flight_takeoff_rounded, address: 'London Gatwick Airport (LGW)'),
      (label: 'Central London', icon: Icons.apartment_rounded, address: 'Central London, UK'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 22, color: AppTheme.brandDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Where can we take you?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.inkMuted,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.brand : AppTheme.midnight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Book',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.midnight : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: isDark ? AppTheme.midnight : Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (final hub in hubs)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Icon(hub.icon, size: 15, color: isDark ? AppTheme.brand : AppTheme.midnight),
                    label: Text(
                      hub.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.ink,
                      ),
                    ),
                    backgroundColor: colors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colors.inkFaint),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    onPressed: () => onSelectHub(hub.label, hub.address),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Service selector cards matching the website's service pillars.
class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid({required this.onSelectService});

  final void Function(String serviceName, String? defaultDropoff) onSelectService;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final services = [
      (
        title: 'Airport Transfer',
        subtitle: 'Meet & greet + flight track',
        icon: Icons.flight_takeoff_rounded,
        dest: 'London Heathrow Airport (LHR)',
      ),
      (
        title: 'Cruise Terminal',
        subtitle: 'Luggage assist & port drop',
        icon: Icons.directions_boat_filled_rounded,
        dest: 'Southampton Cruise Terminals',
      ),
      (
        title: 'By the Hour',
        subtitle: 'Dedicated chauffeur hire',
        icon: Icons.schedule_rounded,
        dest: null,
      ),
      (
        title: 'Long Distance',
        subtitle: 'Intercity premium travel',
        icon: Icons.route_rounded,
        dest: 'Central London, UK',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.ink,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            for (final s in services)
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelectService(s.title, s.dest),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.inkFaint),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.brand.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(s.icon, size: 18, color: AppTheme.brandDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                      Text(
                        s.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Popular fixed fares direct from the Saints Link website.
class _PopularFaresSection extends StatelessWidget {
  const _PopularFaresSection({required this.onSelectFare});

  final void Function(String from, String to) onSelectFare;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final fares = [
      (
        from: 'Southampton',
        to: 'Heathrow Airport (LHR)',
        price: '£115',
        detail: 'Fixed price agreed upfront',
      ),
      (
        from: 'Southampton',
        to: 'Cruise Terminals (Port)',
        price: '£35',
        detail: 'Direct pier & baggage drop',
      ),
      (
        from: 'Southampton',
        to: 'Gatwick Airport (LGW)',
        price: '£125',
        detail: 'Terminal meet & greet',
      ),
      (
        from: 'Southampton',
        to: 'Central London',
        price: '£165',
        detail: 'Intercity executive transfer',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'POPULAR FIXED FARES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.brandDark,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'No surprise meter rates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 165,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: fares.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final fare = fares[index];

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelectFare(fare.from, fare.to),
                child: Container(
                  width: 270,
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
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.brand.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'FIXED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.brandDark,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Text(
                              'From ${fare.price}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: colors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '${fare.from} → ${fare.to}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fare.detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.inkMuted,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            'Book now',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.brandDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 12, color: AppTheme.brandDark),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Executive fleet preview carousel.
class _FleetShowcaseSection extends StatelessWidget {
  const _FleetShowcaseSection({required this.vehicles, required this.onSelectVehicle});

  final List<VehicleCategory> vehicles;
  final ValueChanged<VehicleCategory> onSelectVehicle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (vehicles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Our Executive Fleet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.ink,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 204,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: vehicles.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final v = vehicles[index];

              return Container(
                width: 220,
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.inkFaint),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 114,
                      width: double.infinity,
                      child: VehicleImage(v.slug),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 14, color: colors.inkMuted),
                              Text(' ${v.passengerCapacity}', style: TextStyle(fontSize: 12, color: colors.inkMuted)),
                              const SizedBox(width: 10),
                              Icon(Icons.luggage_outlined, size: 14, color: colors.inkMuted),
                              Text(' ${v.luggageCapacity}', style: TextStyle(fontSize: 12, color: colors.inkMuted)),
                              const Spacer(),
                              InkWell(
                                onTap: () => onSelectVehicle(v),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.brand.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Select',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.brandDark,
                                    ),
                                  ),
                                ),
                              ),
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

/// Trust promises band inspired by config('company.policies') on website.
class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    const items = [
      (
        icon: Icons.verified_outlined,
        title: 'Fixed Price',
        desc: 'Agreed before travel',
      ),
      (
        icon: Icons.airplanemode_active_rounded,
        title: 'Flight Tracked',
        desc: 'Pickup adjusts for delays',
      ),
      (
        icon: Icons.badge_outlined,
        title: 'Licensed Drivers',
        desc: 'Professional local service',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.inkFaint),
        ),
        child: Row(
          children: [
            for (final item in items)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.brand.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: AppTheme.brandDark, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: colors.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.desc,
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.inkMuted,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
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
