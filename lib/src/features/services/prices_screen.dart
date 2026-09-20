import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content.dart';
import '../../core/formatting.dart';
import '../../core/theme.dart';
import '../../domain/place.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/tiles.dart';
import '../booking/booking_flow_controller.dart';
import '../home/widgets/fleet_showcase_section.dart';

/// Popular fixed routes with their "from" prices, filtered by kind of trip.
/// Tapping a route presets the journey form; the quote is what gets charged.
class PricesScreen extends ConsumerStatefulWidget {
  const PricesScreen({super.key});

  @override
  ConsumerState<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends ConsumerState<PricesScreen> {
  var _group = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final groups = Content.routeGroups;
    final routes = groups[_group].routes;
    final vehicles = ref.watch(bookingFlowProvider.select((s) => s.vehicles));

    void book(FixedRoute route) {
      ref
          .read(bookingFlowProvider.notifier)
          .updateJourney(
            (j) => j.copyWith(
              pickup: PlaceSelection(address: route.from),
              dropoff: PlaceSelection(address: route.to),
            ),
          );
      context.push('/book');
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: HeroPage(
              hero: const HeroBanner(
                image: AssetImage('assets/brand/hero-harbor.webp'),
                height: 220,
                bottomInset: OverlapSheet.overlap,
                title: 'Routes & prices',
                subtitle: 'Popular journeys and what they start from.',
                showBack: true,
              ),
              sheet: OverlapSheet(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedTabs(
                      labels: [for (final g in groups) g.label],
                      index: _group,
                      onChanged: (i) => setState(() => _group = i),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colors.inkFaint),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (var i = 0; i < routes.length; i++) ...[
                            if (i > 0)
                              Divider(
                                color: colors.inkFaint,
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                            _RouteRow(
                              route: routes[i],
                              onTap: () => book(routes[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Prices are a guide for a saloon car. Larger vehicles, return journeys and out-of-hours travel are priced on your quote.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.inkMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // The fleet, beside the prices it explains.
          if (vehicles.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: FleetShowcaseSection(
                gutter: 20,
                vehicles: vehicles,
                onSelectVehicle: (v) {
                  ref
                      .read(bookingFlowProvider.notifier)
                      .updateJourney(
                        (j) => j.copyWith(vehicleCategorySlug: v.slug),
                      );
                  context.push('/book');
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ],
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: () => context.push('/book'),
          child: const Text('Price my journey'),
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.route, required this.onTap});

  final FixedRoute route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.from,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: colors.inkMuted),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        size: 13,
                        color: colors.inkMuted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          route.to,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: colors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'from ',
              style: TextStyle(fontSize: 11, color: colors.inkMuted),
            ),
            Text(
              Formatting.money(route.fromPrice),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: colors.ink,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right, color: colors.inkMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
