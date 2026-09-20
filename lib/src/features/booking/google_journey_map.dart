import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme.dart';
import '../../domain/place.dart';
import '../../domain/route_line.dart';
import '../places/current_location.dart';
import 'journey_draft.dart';
import 'journey_markers.dart';
import 'route_line_provider.dart';

/// The journey's located places, pinned and framed, with the road route
/// between them. The line is display only; the fare is measured elsewhere.
class GoogleJourneyMap extends ConsumerStatefulWidget {
  const GoogleJourneyMap({
    super.key,
    required this.journey,
    this.interactive = false,
    this.topPadding = 0,
    this.bottomPadding = 0,
    this.regionWhenEmpty = false,
  });

  /// Space at the bottom covered by a sheet. The framing and the centre use
  /// only the area above it, and follow it as it moves.
  final double bottomPadding;

  final JourneyDraft journey;

  /// With nothing to pin, show the fleet's region instead of a nudge.
  final bool regionWhenEmpty;

  /// Pannable and zoomable. Off for the preview in the screen header, where
  /// a stray drag would fight the page's scroll; on for the expanded sheet.
  final bool interactive;

  /// Space at the top the framing must stay clear of, for the route card the
  /// header floats over the map.
  final int topPadding;

  @override
  ConsumerState<GoogleJourneyMap> createState() => _GoogleJourneyMapState();
}

class _GoogleJourneyMapState extends ConsumerState<GoogleJourneyMap> {
  GoogleMapController? _controller;
  Map<JourneyMarkerKind, BitmapDescriptor>? _icons;
  Timer? _refit;
  RouteLine? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    final colors = context.colors;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final icons = {
      for (final kind in JourneyMarkerKind.values)
        kind: await JourneyMarkers.of(
          kind,
          pixelRatio: dpr,
          ink: colors.ink,
          muted: colors.inkMuted,
        ),
    };
    if (mounted) setState(() => _icons = icons);
  }

  /// Pickup first, stops in order, destination last — only those with a
  /// position, each paired with its letter for the pin.
  List<(String, PlaceSelection)> get _points => [
    ('A', widget.journey.pickup),
    for (final (i, stop) in widget.journey.via.indexed) ('${i + 1}', stop),
    ('B', widget.journey.dropoff),
  ].where((entry) => entry.$2.isLocated).toList();

  @override
  void didUpdateWidget(GoogleJourneyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.journey.pickup != widget.journey.pickup ||
        oldWidget.journey.dropoff != widget.journey.dropoff ||
        oldWidget.journey.via != widget.journey.via ||
        oldWidget.topPadding != widget.topPadding) {
      _frame();
    } else if (oldWidget.bottomPadding != widget.bottomPadding) {
      // The sheet is moving: the padding shifts the view each frame, and the
      // fit is redone once it has settled, with an animated camera.
      _refit?.cancel();
      _refit = Timer(
        const Duration(milliseconds: 120),
        () => _frame(animate: true),
      );
    }
  }

  @override
  void dispose() {
    _refit?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  /// Fit every pin and the route in the area above the sheet. Deferred a
  /// frame because bounds need the map's size, which it reports after layout.
  void _frame({bool animate = false}) {
    final controller = _controller;
    final points = _points;
    if (controller == null || points.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final CameraUpdate update;
      if (points.length == 1) {
        update = CameraUpdate.newLatLngZoom(_latLng(points.single.$2), 14);
      } else {
        var south = double.infinity;
        var north = -double.infinity;
        var west = double.infinity;
        var east = -double.infinity;
        void include(double lat, double lng) {
          south = south < lat ? south : lat;
          north = north > lat ? north : lat;
          west = west < lng ? west : lng;
          east = east > lng ? east : lng;
        }

        for (final (_, place) in points) {
          include(place.latitude!, place.longitude!);
        }
        for (final (lat, lng) in _route?.points ?? const <(double, double)>[]) {
          include(lat, lng);
        }
        update = CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(south, west),
            northeast: LatLng(north, east),
          ),
          56,
        );
      }

      if (animate) {
        controller.animateCamera(update);
      } else {
        controller.moveCamera(update);
      }
    });
  }

  static LatLng _latLng(PlaceSelection place) =>
      LatLng(place.latitude!, place.longitude!);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final points = _points;
    // The location dot only where already permitted; the map never prompts.
    final showLocation = ref.watch(locationGrantedProvider).value ?? false;

    if (points.isEmpty && !widget.regionWhenEmpty) {
      return ColoredBox(
        color: colors.surface,
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              32,
              widget.topPadding.toDouble(),
              32,
              0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, size: 28, color: colors.inkMuted),
                const SizedBox(height: 8),
                Text(
                  'Choose your addresses from the suggestions to see them on the map.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: colors.inkMuted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final route = points.length >= 2
        ? ref.watch(routeLineProvider(routeKey(points.map((p) => p.$2)))).value
        : null;
    if (route != _route) {
      // A route has arrived (or gone): refit so all of it is in view.
      _route = route;
      _frame(animate: true);
    }
    final icons = _icons;
    final markers = icons == null
        ? const <Marker>{}
        : {
            for (final (label, place) in points)
              Marker(
                markerId: MarkerId(label),
                position: _latLng(place),
                anchor: const Offset(0.5, 0.5),
                infoWindow: InfoWindow(title: place.address),
                icon:
                    icons[switch (label) {
                      'A' => JourneyMarkerKind.pickup,
                      'B' => JourneyMarkerKind.dropoff,
                      _ => JourneyMarkerKind.stop,
                    }]!,
              ),
          };

    return ColoredBox(
      // Under the tiles while they load, and behind them in the test harness,
      // where no platform view is drawn.
      color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFEAF0EF),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: points.isEmpty ? _southampton : _latLng(points.first.$2),
          zoom: points.isEmpty ? 10 : 11,
        ),
        markers: markers,
        polylines: {
          if (route != null)
            Polyline(
              polylineId: const PolylineId('route'),
              points: [for (final (lat, lng) in route.points) LatLng(lat, lng)],
              color: colors.ink,
              width: 4,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              jointType: JointType.round,
            ),
        },
        style: isDark ? _darkStyle : null,
        padding: EdgeInsets.only(
          top: widget.topPadding.toDouble(),
          bottom: widget.bottomPadding,
        ),
        onMapCreated: (controller) {
          _controller = controller;
          _frame();
        },
        // The preview is a picture: no gestures, and lite mode on Android.
        liteModeEnabled: !widget.interactive,
        zoomGesturesEnabled: widget.interactive,
        scrollGesturesEnabled: widget.interactive,
        rotateGesturesEnabled: widget.interactive,
        tiltGesturesEnabled: widget.interactive,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: widget.interactive,
        myLocationEnabled: showLocation,
        myLocationButtonEnabled: showLocation && widget.interactive,
        buildingsEnabled: false,
      ),
    );
  }
}

/// Where the fleet is based; where an empty map looks.
const _southampton = LatLng(50.9097, -1.4044);

/// Night styling on the app's dark ground, with POI clutter off.
const _darkStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1c1c1e"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8e8e93"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1c1c1e"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#3a3a3c"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2e"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1c1c1e"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#48484a"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#aeaeb2"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0d1b2a"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#5c6b7a"}]},
  {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#222224"}]}
]
''';
