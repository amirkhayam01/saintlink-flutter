import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/theme_controller.dart';
import '../../domain/place.dart';
import '../../widgets/hero_banner.dart';
import '../auth/auth_controller.dart';
import '../booking/booking_flow_controller.dart';
import '../booking/journey_draft.dart';
import '../trips/trips_controller.dart';
import 'widgets/fleet_showcase_section.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/popular_fares_section.dart';
import 'widgets/search_launcher.dart';
import 'widgets/services_grid.dart';
import 'widgets/trust_strip.dart';
import 'widgets/upcoming_trip_banner.dart';

/// The landing screen: a launcher, not a form.
///
/// Photo hero with the greeting, then a sheet that rides up over it carrying
/// the "where to" bar, the customer's next trip if they have one, the four
/// service tiles, the trust promises, popular fixed fares and the fleet. The
/// booking form itself lives on /book; every tile here just presets it.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// The side gutter every section on this screen shares. Carousels bleed to
  /// the screen edge and use it as their content padding instead.
  static const double gutter = 18;

  /// Vertical rhythm between sections.
  static const double sectionGap = 24;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void presetAndBook(JourneyDraft Function(JourneyDraft) update) {
      bookingController.reset();
      bookingController.updateJourney(update);
      context.go('/book');
    }

    return Scaffold(
      backgroundColor: colors.surface,
      body: RefreshIndicator(
        color: colors.accent,
        backgroundColor: colors.card,
        edgeOffset: MediaQuery.paddingOf(context).top,
        onRefresh: () async {
          try {
            await Future.wait([
              bookingController.loadVehicles(force: true),
              if (auth.isSignedIn) ref.refresh(tripsProvider.future),
            ]);
          } catch (_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to refresh. Please try again.'),
              ),
            );
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: HeroPage(
                hero: HeroBanner(
                  image: const AssetImage('assets/brand/hero.webp'),
                  height: 240,
                  bottomInset: OverlapSheet.overlap,
                  title:
                      '$greetingText${firstName != null && firstName.isNotEmpty ? ', $firstName' : ''}',
                  subtitle: 'Fixed prices, licensed drivers, and a car that is there when your flight is.',
                  leading: Image.asset(
                    'assets/brand/logo-dark.png',
                    height: 30,
                  ),
                  actions: [
                    HeroIconButton(
                      icon: isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      semanticLabel: 'Switch theme',
                      onPressed: () =>
                          ref.read(themeModeProvider.notifier).toggleTheme(),
                    ),
                    const SizedBox(width: 8),
                    HomeAccountChip(
                      auth: auth,
                      onProfile: () => context.go('/profile'),
                      onSignIn: () => context.push('/sign-in'),
                    ),
                  ],
                ),
                // No side padding on the sheet itself: the chip row inside the
                // launcher scrolls edge to edge, so each block sets its own gutter.
                sheet: OverlapSheet(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SearchLauncher(
                        gutter: gutter,
                        onSelectPlace: (place) =>
                            presetAndBook((j) => j.copyWith(dropoff: place)),
                        onSelectHub: (name, address) => presetAndBook(
                          (j) => j.copyWith(
                            dropoff: PlaceSelection(address: address),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: gutter),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            UpcomingTripBanner(
                              auth: auth,
                              spacingBelow: sectionGap,
                            ),
                            ServicesGrid(
                              onSelectService: (serviceName, defaultDropoff) {
                                if (defaultDropoff == null) {
                                  bookingController.reset();
                                  return context.go('/book');
                                }
                                presetAndBook(
                                  (j) => j.copyWith(
                                    dropoff: PlaceSelection(
                                      address: defaultDropoff,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: sectionGap),
                            const TrustStrip(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: sectionGap)),
            SliverToBoxAdapter(
              child: PopularFaresSection(
                gutter: gutter,
                onSelectFare: (from, to) => presetAndBook(
                  (j) => j.copyWith(
                    pickup: PlaceSelection(address: from),
                    dropoff: PlaceSelection(address: to),
                  ),
                ),
              ),
            ),
            if (bookingState.vehicles.isNotEmpty) ...[
              const SliverToBoxAdapter(child: SizedBox(height: sectionGap)),
              SliverToBoxAdapter(
                child: FleetShowcaseSection(
                  gutter: gutter,
                  vehicles: bookingState.vehicles,
                  onSelectVehicle: (v) => presetAndBook(
                    (j) => j.copyWith(vehicleCategorySlug: v.slug),
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: SizedBox(
                height: 28 + MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
