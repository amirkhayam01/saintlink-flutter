import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/inner_screen_header.dart';
import '../../widgets/route_timeline.dart';
import 'journey_draft.dart';
import 'google_journey_map.dart';

/// A compact toolbar above a route map with its address overlay.
class BookingScreenHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const BookingScreenHeader({
    super.key,
    required this.title,
    required this.journey,
    this.onBack,
    this.expandable = false,
    this.actions = const [],
    this.mapHeight = 300,
    this.curvedEdge = true,
  });

  /// See [InnerScreenHeader.curvedEdge].
  final bool curvedEdge;

  final String title;
  final JourneyDraft journey;
  final VoidCallback? onBack;
  final bool expandable;
  final List<Widget> actions;
  final double mapHeight;

  @override
  Size get preferredSize =>
      Size.fromHeight((curvedEdge ? 80 : 60) + (expandable ? mapHeight : 0));

  @override
  Widget build(BuildContext context) => InnerScreenHeader(
    title: title,
    onBack: onBack,
    curvedEdge: curvedEdge,
    contentHeight: expandable ? mapHeight : 0,
    headerContent: expandable && mapHeight > 0
        ? Stack(
            fit: StackFit.expand,
            children: [
              GoogleJourneyMap(
                journey: journey,
                topPadding: MediaQuery.textScalerOf(context).scale(13) > 18
                    ? 104
                    : 84,
              ),
              Positioned(
                top: 12,
                left: 14,
                right: 14,
                child: Align(
                  alignment: Alignment.topRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => showBookingMap(context, journey),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                          child: RouteTimeline(
                            dense: true,
                            points: [
                              RoutePoint(address: journey.pickup.address),
                              RoutePoint(address: journey.dropoff.address),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : null,
    actions: [
      ...actions,
      if (expandable)
        IconButton(
          tooltip: 'Expand map',
          onPressed: () => showBookingMap(context, journey),
          icon: const Icon(Icons.open_in_full_rounded, size: 20),
        ),
    ],
  );
}

Future<void> showBookingMap(BuildContext context, JourneyDraft journey) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 720),
      builder: (context) => FractionallySizedBox(
        heightFactor: .78,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Journey map',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close map',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRect(
                child: GoogleJourneyMap(journey: journey, interactive: true),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RouteTimeline(
                      points: [
                        RoutePoint(
                          label: 'Pickup',
                          address: journey.pickup.address,
                        ),
                        for (final (i, stop) in journey.via.indexed)
                          if (!stop.isEmpty)
                            RoutePoint(
                              label: 'Stop ${i + 1}',
                              address: stop.address,
                            ),
                        RoutePoint(
                          label: 'Destination',
                          address: journey.dropoff.address,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Google Maps',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
