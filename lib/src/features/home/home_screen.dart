import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/theme_controller.dart';
import '../../domain/place.dart';
import '../auth/auth_controller.dart';
import '../booking/booking_flow_controller.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/app_drawer.dart';
import 'widgets/upcoming_trip_banner.dart';
import 'widgets/search_launcher.dart';
import 'widgets/services_grid.dart';
import 'widgets/popular_fares_section.dart';
import 'widgets/fleet_showcase_section.dart';
import 'widgets/trust_strip.dart';

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
      drawer: const AppDrawer(),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: HomeTopBar(
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
                child: UpcomingTripBanner(auth: auth),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SearchLauncher(
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
                child: ServicesGrid(
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
              child: PopularFaresSection(
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
              child: FleetShowcaseSection(
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
            const SliverToBoxAdapter(child: TrustStrip()),
            const SliverToBoxAdapter(child: SizedBox(height: 36)),
          ],
        ),
      ),
    );
  }
}
