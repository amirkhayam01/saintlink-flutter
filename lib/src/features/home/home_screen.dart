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
import 'widgets/home_top_bar.dart';
import 'widgets/popular_fares_section.dart';
import 'widgets/recent_places_section.dart';
import 'widgets/search_launcher.dart';
import 'widgets/services_grid.dart';
import 'widgets/trust_strip.dart';
import 'widgets/upcoming_trip_banner.dart';

/// The front door, and where a booking starts.
///
/// Photo hero with the greeting, then a sheet that rides up over it. What a
/// returning customer needs sits at the top, in the order they need it: the
/// trip they already have, where to next, the places they keep going back
/// to, and a plain door into the full form. The four service tiles, the
/// trust promises and the popular fares follow for anyone still deciding.
/// The booking form itself lives on /book, pushed over this screen; every
/// tile here just presets it.
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
    final bookingController = ref.read(bookingFlowProvider.notifier);
    final firstName = auth.customer?.firstName;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void presetAndBook(JourneyDraft Function(JourneyDraft) update) {
      bookingController.reset();
      bookingController.updateJourney(update);
      context.push('/book');
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
                      // A trip already booked outranks everything else on the
                      // page for the person who booked it. Gone when there is none.
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: gutter),
                        child: UpcomingTripBanner(auth: auth, spacingBelow: 16),
                      ),
                      SearchLauncher(
                        gutter: gutter,
                        onSelectPlace: (place) =>
                            presetAndBook((j) => j.copyWith(dropoff: place)),
                        onSelectHub: (place) =>
                            presetAndBook((j) => j.copyWith(dropoff: place)),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: gutter),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            RecentPlacesSection(
                              onSelect: (place) => presetAndBook(
                                (j) => j.copyWith(dropoff: place),
                              ),
                              spacingBelow: 18,
                            ),
                            /*
                             * The one explicit door into the whole form, for
                             * someone who wants to set the pickup, the date or
                             * a return before naming a destination. The Book
                             * tab used to be this; a button under the search
                             * is where a hand already is.
                             */
                            FilledButton.icon(
                              onPressed: () {
                                bookingController.reset();
                                context.push('/book');
                              },
                              icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                              label: const Text('Plan a journey'),
                            ),
                            const SizedBox(height: sectionGap),
                            ServicesGrid(
                              onSelectService: (serviceName, defaultDropoff) {
                                if (defaultDropoff == null) {
                                  bookingController.reset();
                                  context.push('/book');
                                  return;
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
