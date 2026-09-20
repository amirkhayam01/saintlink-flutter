import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/inner_screen_header.dart';
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
  Size get preferredSize => Size.fromHeight(
    (curvedEdge ? 80 : 60) + (expandable ? mapHeight : 0),
  );

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
                    child: Material(
                      color: const Color(0xF7FFFFFF),
                      elevation: 3,
                      shadowColor: const Color(0x33020617),
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => showBookingMap(context, journey),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _RouteGlyphs(),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _HeaderAddress(
                                        semanticsLabel: 'From',
                                        address: journey.pickup.address,
                                      ),
                                      const SizedBox(height: 10),
                                      _HeaderAddress(
                                        semanticsLabel: 'To',
                                        address: journey.dropoff.address,
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

/// Pickup dot, dotted connector, destination pin - the same visual language
/// as the markers on the map itself.
class _RouteGlyphs extends StatelessWidget {
  const _RouteGlyphs();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 18,
      child: Column(
        children: [
          const Icon(
            Icons.trip_origin_rounded,
            size: 16,
            color: AppTheme.midnight,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.location_on_rounded,
            size: 18,
            color: AppTheme.midnight,
          ),
        ],
      ),
    ),
  );
}

class _HeaderAddress extends StatelessWidget {
  const _HeaderAddress({required this.semanticsLabel, required this.address});
  final String semanticsLabel;
  final String address;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$semanticsLabel: $address',
    excludeSemantics: true,
    child: Tooltip(
      message: address,
      child: Text(
        address,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 13,
          height: 1.25,
          fontWeight: FontWeight.w600,
          color: AppTheme.midnight,
        ),
      ),
    ),
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
                    for (final entry in [
                      ('Pickup', journey.pickup, 'A'),
                      ('Destination', journey.dropoff, 'B'),
                    ])
                      if (!entry.$2.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _MapPin(label: entry.$3),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.$1,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.colors.inkMuted,
                                      ),
                                    ),
                                    Text(
                                      entry.$2.address,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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

class _MapPin extends StatelessWidget {
  const _MapPin({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    width: 28,
    height: 28,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppTheme.brand,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [BoxShadow(color: Color(0x33020617), blurRadius: 5)],
    ),
    child: Text(
      label,
      textScaler: TextScaler.noScaling,
      style: const TextStyle(
        color: AppTheme.midnight,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
  );
}
