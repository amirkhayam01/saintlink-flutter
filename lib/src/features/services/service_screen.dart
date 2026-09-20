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

/// Which of the two landing pages this is; they share one layout.
enum ServiceKind {
  airport(
    title: 'Airport transfers',
    image: 'assets/brand/hero-airport.webp',
    listTitle: 'Airports we serve',
    listSubtitle: 'From Southampton, one way, saloon car. Your quote is exact.',
    destinations: Content.airports,
    icon: Icons.flight_takeoff_rounded,
  ),
  cruise(
    title: 'Cruise terminal transfers',
    image: 'assets/brand/hero-cruise.webp',
    listTitle: 'Terminals we serve',
    listSubtitle:
        'From Southampton Central, one way, saloon car. Your quote is exact.',
    destinations: Content.cruiseTerminals,
    icon: Icons.directions_boat_filled_rounded,
  );

  const ServiceKind({
    required this.title,
    required this.image,
    required this.listTitle,
    required this.listSubtitle,
    required this.destinations,
    required this.icon,
  });

  final String title;
  final String image;
  final String listTitle;
  final String listSubtitle;
  final List<Destination> destinations;
  final IconData icon;
}

class ServiceScreen extends ConsumerWidget {
  const ServiceScreen({super.key, required this.kind});

  final ServiceKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void quoteFor(Destination? destination) {
      ref
          .read(bookingFlowProvider.notifier)
          .updateJourney(
            (j) => j.copyWith(
              pickup: j.pickup.isEmpty
                  ? const PlaceSelection(address: 'Southampton, UK')
                  : j.pickup,
              dropoff: destination == null
                  ? j.dropoff
                  : PlaceSelection(address: destination.address),
            ),
          );
      context.push('/book');
    }

    return Scaffold(
      body: RefreshIndicator(
        color: context.colors.accent,
        backgroundColor: context.colors.card,
        edgeOffset: MediaQuery.paddingOf(context).top,
        onRefresh: () => ref
            .read(bookingFlowProvider.notifier)
            .loadVehicles(force: true)
            .catchError((_) {}),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: HeroPage(
                hero: HeroBanner(
                  image: AssetImage(kind.image),
                  height: 240,
                  bottomInset: OverlapSheet.overlap,
                  title: kind.title,
                  showBack: true,
                ),
                sheet: OverlapSheet(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionTitle(kind.listTitle, subtitle: kind.listSubtitle),
                      const SizedBox(height: 14),
                      for (final destination in kind.destinations) ...[
                        _DestinationRow(
                          destination: destination,
                          icon: kind.icon,
                          onTap: () => quoteFor(destination),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: () => quoteFor(null),
          child: const Text('Get a quote'),
        ),
      ),
    );
  }
}

class _DestinationRow extends StatelessWidget {
  const _DestinationRow({
    required this.destination,
    required this.icon,
    required this.onTap,
  });

  final Destination destination;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.inkFaint),
          ),
          child: Row(
            children: [
              IconDisc(icon, size: 42),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            destination.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: colors.ink,
                            ),
                          ),
                        ),
                        if (destination.code.isNotEmpty)
                          const SizedBox(width: 6),
                        if (destination.code.isNotEmpty)
                          Text(
                            destination.code,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: colors.inkMuted,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination.travelTime,
                      style: TextStyle(fontSize: 12, color: colors.inkMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'from',
                    style: TextStyle(fontSize: 10, color: colors.inkMuted),
                  ),
                  Text(
                    Formatting.money(destination.fromPrice),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: colors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: colors.inkMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
