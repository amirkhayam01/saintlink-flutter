import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme.dart';
import '../../domain/place.dart';
import '../places/current_location.dart';
import 'journey_draft.dart';

/// The journey on a map: every end of it that has a position, framed.
///
/// This used to be a WebView running the Maps JavaScript SDK, which paid for
/// a browser, an HTML load and a network fetch of the SDK on every appearance
/// — hence the spinner, the 25-second timeout and the "Retry map" button it
/// needed. The native SDK is compiled in and caches its tiles, so it draws on
/// the first frame and none of that apparatus is needed any more.
///
/// Only located places are shown. A typed address the customer never picked
/// from the suggestions has no position, and guessing one would put a pin
/// somewhere the driver is not going. There is deliberately no route line:
/// the server measures a journey as a straight line scaled by a constant and
/// never asks Google for a route, so drawing one would claim a precision the
/// fare does not have.
class GoogleJourneyMap extends ConsumerStatefulWidget {
  const GoogleJourneyMap({
    super.key,
    required this.journey,
    this.interactive = false,
    this.topPadding = 0,
  });

  final JourneyDraft journey;

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

  /// Pickup first, stops in order, destination last — only those with a
  /// position, each paired with its letter for the pin.
  List<(String, PlaceSelection)> get _points => [
    ('A', widget.journey.pickup),
    for (final (i, stop) in widget.journey.via.indexed)
      ('${i + 1}', stop),
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
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Fit every pin in view. Deferred a frame because the map reports its
  /// size only after layout, and bounds need a size to be turned into a zoom.
  void _frame() {
    final controller = _controller;
    final points = _points;
    if (controller == null || points.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (points.length == 1) {
        controller.moveCamera(
          CameraUpdate.newLatLngZoom(_latLng(points.single.$2), 14),
        );
        return;
      }

      var south = double.infinity, north = -double.infinity;
      var west = double.infinity, east = -double.infinity;
      for (final (_, place) in points) {
        south = south < place.latitude! ? south : place.latitude!;
        north = north > place.latitude! ? north : place.latitude!;
        west = west < place.longitude! ? west : place.longitude!;
        east = east > place.longitude! ? east : place.longitude!;
      }

      controller.moveCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(south, west),
            northeast: LatLng(north, east),
          ),
          56,
        ),
      );
    });
  }

  static LatLng _latLng(PlaceSelection place) =>
      LatLng(place.latitude!, place.longitude!);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final points = _points;
    /*
     * The "you are here" dot, only where the app already may. Map loads are
     * free and the dot costs nothing, but it must never be the reason for a
     * permission prompt — that stays on the pickup field, where there is a
     * reason the customer can see.
     */
    final showLocation = ref.watch(locationGrantedProvider).value ?? false;

    if (points.isEmpty) {
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

    final markers = {
      for (final (label, place) in points)
        Marker(
          markerId: MarkerId(label),
          position: _latLng(place),
          infoWindow: InfoWindow(title: place.address),
          icon: BitmapDescriptor.defaultMarkerWithHue(switch (label) {
            'A' => BitmapDescriptor.hueAzure,
            'B' => BitmapDescriptor.hueYellow,
            _ => BitmapDescriptor.hueOrange,
          }),
        ),
    };

    return ColoredBox(
      // Under the tiles while they load, and behind them in the test harness,
      // where no platform view is drawn.
      color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFEAF0EF),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _latLng(points.first.$2),
          zoom: 11,
        ),
        markers: markers,
        style: isDark ? _darkStyle : null,
        padding: EdgeInsets.only(top: widget.topPadding.toDouble()),
        onMapCreated: (controller) {
          _controller = controller;
          _frame();
        },
        /*
         * The header preview is a picture of the route, not a map to explore:
         * every gesture off so it can never steal the page's scroll, and lite
         * mode on Android so it renders as a bitmap in one go.
         */
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

/// Google's night styling, trimmed to what this map shows: land, water and
/// roads on the app's dark ground, with the point-of-interest clutter that
/// competes with the pins switched off.
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
