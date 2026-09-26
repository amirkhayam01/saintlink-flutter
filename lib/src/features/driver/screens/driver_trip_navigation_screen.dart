import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme.dart';
import '../../../widgets/hero_banner.dart';
import '../driver_state.dart';

class DriverTripNavigationScreen extends ConsumerStatefulWidget {
  const DriverTripNavigationScreen({super.key});

  @override
  ConsumerState<DriverTripNavigationScreen> createState() =>
      _DriverTripNavigationScreenState();
}

class _DriverTripNavigationScreenState
    extends ConsumerState<DriverTripNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0; // 0: Heading to pickup, 1: Arrived, 2: On trip, 3: Completed

  GoogleMapController? _mapController;
  BitmapDescriptor? _carIcon;
  BitmapDescriptor? _destinationIcon;

  late final AnimationController _carAnimController;

  // Real-world road polyline following actual Southampton streets (182 waypoints)
  static const List<LatLng> _routePoints = [
    LatLng(50.90804, -1.41356),
    LatLng(50.90795, -1.41220),
    LatLng(50.90791, -1.41163),
    LatLng(50.90786, -1.41125),
    LatLng(50.90774, -1.41049),
    LatLng(50.90773, -1.41033),
    LatLng(50.90828, -1.40910),
    LatLng(50.90843, -1.40878),
    LatLng(50.90859, -1.40845),
    LatLng(50.90893, -1.40874),
    LatLng(50.90905, -1.40880),
    LatLng(50.90919, -1.40883),
    LatLng(50.90940, -1.40878),
    LatLng(50.90947, -1.40874),
    LatLng(50.90960, -1.40858),
    LatLng(50.90970, -1.40839),
    LatLng(50.90985, -1.40774),
    LatLng(50.91006, -1.40668),
    LatLng(50.91013, -1.40632),
    LatLng(50.91027, -1.40576),
    LatLng(50.91050, -1.40489),
    LatLng(50.91074, -1.40402),
    LatLng(50.91091, -1.40333),
    LatLng(50.91094, -1.40302),
    LatLng(50.91092, -1.40276),
    LatLng(50.91089, -1.40258),
    LatLng(50.91078, -1.40222),
    LatLng(50.91071, -1.40199),
    LatLng(50.91071, -1.40189),
    LatLng(50.91070, -1.40181),
    LatLng(50.91070, -1.40173),
    LatLng(50.91075, -1.40155),
    LatLng(50.91094, -1.40144),
    LatLng(50.91101, -1.40146),
    LatLng(50.91125, -1.40134),
    LatLng(50.91144, -1.40124),
    LatLng(50.91180, -1.40098),
    LatLng(50.91210, -1.40081),
    LatLng(50.91219, -1.40075),
    LatLng(50.91229, -1.40051),
    LatLng(50.91240, -1.40032),
    LatLng(50.91251, -1.40009),
    LatLng(50.91309, -1.39949),
    LatLng(50.91363, -1.39893),
    LatLng(50.91409, -1.39848),
    LatLng(50.91473, -1.39785),
    LatLng(50.91503, -1.39755),
    LatLng(50.91541, -1.39714),
    LatLng(50.91578, -1.39667),
    LatLng(50.91601, -1.39641),
    LatLng(50.91641, -1.39613),
    LatLng(50.91690, -1.39582),
    LatLng(50.91713, -1.39568),
    LatLng(50.91735, -1.39561),
    LatLng(50.91795, -1.39549),
    LatLng(50.91829, -1.39545),
    LatLng(50.91864, -1.39544),
    LatLng(50.91880, -1.39541),
    LatLng(50.91895, -1.39532),
    LatLng(50.91900, -1.39530),
    LatLng(50.91912, -1.39509),
    LatLng(50.91924, -1.39487),
    LatLng(50.91941, -1.39451),
    LatLng(50.91957, -1.39410),
    LatLng(50.91965, -1.39378),
    LatLng(50.91978, -1.39315),
    LatLng(50.91993, -1.39233),
    LatLng(50.92013, -1.39127),
    LatLng(50.92031, -1.39047),
    LatLng(50.92044, -1.39006),
    LatLng(50.92050, -1.38991),
    LatLng(50.92072, -1.38953),
    LatLng(50.92093, -1.38929),
    LatLng(50.92107, -1.38918),
    LatLng(50.92147, -1.38891),
    LatLng(50.92200, -1.38858),
    LatLng(50.92276, -1.38808),
    LatLng(50.92360, -1.38756),
    LatLng(50.92402, -1.38733),
    LatLng(50.92423, -1.38733),
    LatLng(50.92443, -1.38733),
    LatLng(50.92453, -1.38736),
    LatLng(50.92458, -1.38736),
    LatLng(50.92500, -1.38732),
    LatLng(50.92519, -1.38718),
    LatLng(50.92540, -1.38699),
    LatLng(50.92550, -1.38688),
    LatLng(50.92555, -1.38678),
    LatLng(50.92556, -1.38672),
    LatLng(50.92564, -1.38662),
    LatLng(50.92581, -1.38638),
    LatLng(50.92590, -1.38626),
    LatLng(50.92610, -1.38610),
    LatLng(50.92625, -1.38598),
    LatLng(50.92652, -1.38582),
    LatLng(50.92739, -1.38530),
    LatLng(50.92805, -1.38491),
    LatLng(50.92821, -1.38481),
    LatLng(50.92876, -1.38446),
    LatLng(50.92919, -1.38422),
    LatLng(50.92974, -1.38389),
    LatLng(50.93053, -1.38344),
    LatLng(50.93278, -1.38214),
    LatLng(50.93413, -1.38135),
    LatLng(50.93461, -1.38102),
    LatLng(50.93683, -1.37967),
    LatLng(50.93809, -1.37889),
    LatLng(50.93845, -1.37867),
    LatLng(50.93957, -1.37801),
    LatLng(50.93997, -1.37780),
    LatLng(50.94008, -1.37774),
    LatLng(50.94020, -1.37775),
    LatLng(50.94040, -1.37776),
    LatLng(50.94048, -1.37777),
    LatLng(50.94057, -1.37786),
    LatLng(50.94069, -1.37764),
    LatLng(50.94081, -1.37745),
    LatLng(50.94096, -1.37728),
    LatLng(50.94134, -1.37687),
    LatLng(50.94162, -1.37661),
    LatLng(50.94215, -1.37612),
    LatLng(50.94222, -1.37584),
    LatLng(50.94222, -1.37558),
    LatLng(50.94218, -1.37523),
    LatLng(50.94215, -1.37499),
    LatLng(50.94206, -1.37391),
    LatLng(50.94203, -1.37366),
    LatLng(50.94201, -1.37349),
    LatLng(50.94200, -1.37343),
    LatLng(50.94215, -1.37285),
    LatLng(50.94226, -1.37263),
    LatLng(50.94231, -1.37255),
    LatLng(50.94248, -1.37234),
    LatLng(50.94310, -1.37157),
    LatLng(50.94398, -1.37044),
    LatLng(50.94445, -1.36985),
    LatLng(50.94465, -1.36956),
    LatLng(50.94492, -1.36921),
    LatLng(50.94528, -1.36874),
    LatLng(50.94557, -1.36841),
    LatLng(50.94603, -1.36796),
    LatLng(50.94637, -1.36765),
    LatLng(50.94664, -1.36738),
    LatLng(50.94678, -1.36722),
    LatLng(50.94700, -1.36695),
    LatLng(50.94721, -1.36666),
    LatLng(50.94743, -1.36632),
    LatLng(50.94756, -1.36613),
    LatLng(50.94769, -1.36590),
    LatLng(50.94780, -1.36564),
    LatLng(50.94795, -1.36533),
    LatLng(50.94801, -1.36528),
    LatLng(50.94805, -1.36521),
    LatLng(50.94808, -1.36511),
    LatLng(50.94809, -1.36500),
    LatLng(50.94807, -1.36489),
    LatLng(50.94803, -1.36481),
    LatLng(50.94800, -1.36477),
    LatLng(50.94794, -1.36455),
    LatLng(50.94791, -1.36438),
    LatLng(50.94794, -1.36426),
    LatLng(50.94799, -1.36417),
    LatLng(50.94803, -1.36414),
    LatLng(50.94840, -1.36399),
    LatLng(50.94866, -1.36389),
    LatLng(50.94900, -1.36378),
    LatLng(50.94922, -1.36377),
    LatLng(50.94963, -1.36358),
    LatLng(50.94988, -1.36343),
    LatLng(50.94999, -1.36334),
    LatLng(50.95031, -1.36299),
    LatLng(50.95108, -1.36207),
    LatLng(50.95113, -1.36202),
    LatLng(50.95109, -1.36196),
    LatLng(50.95100, -1.36173),
    LatLng(50.95089, -1.36128),
    LatLng(50.95082, -1.36092),
    LatLng(50.95082, -1.36080),
    LatLng(50.95083, -1.36064),
    LatLng(50.95081, -1.36054),
    LatLng(50.95077, -1.36051),
    LatLng(50.95072, -1.36051),
  ];

  late LatLng _currentCarPosition = _routePoints.first;
  late double _currentCarBearing =
      _calculateBearing(_routePoints[0], _routePoints[1]);

  final Map<int, BitmapDescriptor> _carIconCache = {};
  double _lastRenderedBearing = -999.0;

  @override
  void initState() {
    super.initState();
    _carAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    _loadCustomMarkers();
  }

  @override
  void dispose() {
    _carAnimController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadCustomMarkers() async {
    final dpr = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    try {
      final initialBearing = _calculateBearing(_routePoints[0], _routePoints[1]);
      final car = await _getCarIconForBearing(initialBearing, dpr);
      final dest = await _createPointMarker(
        label: 'B',
        color: AppTheme.midnight,
        borderColor: AppTheme.brand,
        pixelRatio: dpr,
      );

      if (mounted) {
        setState(() {
          _carIcon = car;
          _destinationIcon = dest;
          _lastRenderedBearing = initialBearing;
        });
      }
    } catch (_) {
      // Fallback to default markers if canvas generation is unavailable
    }
  }

  Future<BitmapDescriptor> _getCarIconForBearing(double bearing, double dpr) async {
    // Round to nearest 5 degrees for optimal caching
    final rounded = ((((bearing % 360) + 360) % 360) / 5.0).round() * 5 % 360;
    if (_carIconCache.containsKey(rounded)) {
      return _carIconCache[rounded]!;
    }
    final icon = await _createRotatedCarMarker(dpr, rounded.toDouble());
    _carIconCache[rounded] = icon;
    return icon;
  }

  static double _calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * (math.pi / 180.0);
    final lon1 = start.longitude * (math.pi / 180.0);
    final lat2 = end.latitude * (math.pi / 180.0);
    final lon2 = end.longitude * (math.pi / 180.0);
    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final radians = math.atan2(y, x);
    return (radians * (180.0 / math.pi) + 360.0) % 360.0;
  }

  static double _lerpAngle(double a, double b, double t) {
    var diff = (b - a) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    return (a + diff * t) % 360.0;
  }

  void _animateAlongWaypoints(List<LatLng> waypoints, {VoidCallback? onComplete}) {
    if (waypoints.length < 2) return;

    _carAnimController.stop();
    _carAnimController.reset();

    final segmentCount = waypoints.length - 1;

    void updatePosition() async {
      final t = _carAnimController.value;
      final totalProgress = (t * segmentCount).clamp(0.0, segmentCount.toDouble());
      final segIndex = totalProgress.floor().clamp(0, segmentCount - 1);
      final segT = (totalProgress - segIndex).clamp(0.0, 1.0);

      final p1 = waypoints[segIndex];
      final p2 = waypoints[segIndex + 1];

      final lat = p1.latitude + (p2.latitude - p1.latitude) * segT;
      final lng = p1.longitude + (p2.longitude - p1.longitude) * segT;

      final segBearing = _calculateBearing(p1, p2);
      final nextBearing = (segIndex + 2 < waypoints.length)
          ? _calculateBearing(p2, waypoints[segIndex + 2])
          : segBearing;

      // Smoothly steer into turn in the last 30% of segment approaching corner
      final smoothBearing = (segT > 0.65)
          ? _lerpAngle(segBearing, nextBearing, (segT - 0.65) / 0.35)
          : segBearing;

      final newPos = LatLng(lat, lng);
      _currentCarPosition = newPos;
      _currentCarBearing = smoothBearing;

      // Only re-generate icon when angle changes by at least 4 degrees
      final dpr = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
      if ((smoothBearing - _lastRenderedBearing).abs() >= 4.0) {
        _lastRenderedBearing = smoothBearing;
        final icon = await _getCarIconForBearing(smoothBearing, dpr);
        if (mounted) {
          setState(() {
            _carIcon = icon;
          });
        }
      } else {
        if (mounted) setState(() {});
      }

      // Smooth camera track
      _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
    }

    _carAnimController.addListener(updatePosition);
    _carAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _carAnimController.removeListener(updatePosition);
        onComplete?.call();
      }
    });

    _carAnimController.forward(from: 0.0);
  }

  void _centreOnCar() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentCarPosition, 15.0),
    );
  }

  void _fitRoute() {
    final controller = _mapController;
    if (controller == null) return;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: const LatLng(50.902, -1.420),
          northeast: const LatLng(50.955, -1.350),
        ),
        60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(driverControllerProvider);
    final job = state.activeJob;

    final actionButtonText = switch (_step) {
      0 => '📍 Arrived at Pickup',
      1 => '▶ Start Trip',
      _ => '✓ Complete Trip',
    };

    final (etaText, distanceText, statusSubtitle) = switch (_step) {
      0 => ('ETA: 3 min', 'Distance: 1.2 km', 'Heading to Pickup Station'),
      1 => ('At Pickup', 'Distance: 8.4 km', 'Waiting for Passenger Boarding'),
      _ => ('ETA: 9 min', 'Distance: 4.2 km', 'En Route to Southampton Airport'),
    };

    final markers = <Marker>{
      // Destination Pin (Point B at Southampton Airport)
      Marker(
        markerId: const MarkerId('destination_marker'),
        position: _routePoints.last,
        icon: _destinationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        anchor: const Offset(0.5, 0.5),
        infoWindow: const InfoWindow(
          title: 'Destination (Point B)',
          snippet: 'Southampton Airport Terminal (SOU)',
        ),
        zIndexInt: 2,
      ),
      // Live Vehicle Icon Marker (Pointed straight to road, smoothly rotating on turns)
      Marker(
        markerId: const MarkerId('driver_car_marker'),
        position: _currentCarPosition,
        icon: _carIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        anchor: const Offset(0.5, 0.5),
        rotation: _currentCarBearing,
        flat: true,
        zIndexInt: 10,
        infoWindow: InfoWindow(
          title: _step == 0 ? 'Pickup: Southampton Central' : 'Your Vehicle',
          snippet: statusSubtitle,
        ),
      ),
    };

    final polylines = <Polyline>{
      // High-contrast background casing
      Polyline(
        polylineId: const PolylineId('route_casing'),
        points: _routePoints,
        color: AppTheme.midnight.withValues(alpha: 0.65),
        width: 8,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        zIndex: 1,
      ),
      // Vibrant Saintlink Brand Polyline
      Polyline(
        polylineId: const PolylineId('route_main'),
        points: _routePoints,
        color: AppTheme.brand,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        zIndex: 2,
      ),
    };

    return Scaffold(
      backgroundColor: colors.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final topInset = MediaQuery.paddingOf(context).top;
          final bottomInset = MediaQuery.paddingOf(context).bottom;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. Full-Screen Edge-to-Edge Official Google Map (Touches all screen edges) ──
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(50.90804, -1.41356),
                    zoom: 16.0,
                  ),
                  markers: markers,
                  polylines: polylines,
                  style: isDark ? _darkMapStyle : null,
                  minMaxZoomPreference: const MinMaxZoomPreference(11.5, 18.5),
                  webGestureHandling: WebGestureHandling.cooperative,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
              ),

              // ── 2. Floating Top-Left Back Button ──
              Positioned(
                top: topInset + 10,
                left: 14,
                child: HeroIconButton(
                  icon: Icons.arrow_back_rounded,
                  semanticLabel: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // ── 3. Floating Live Status Pill (Top Center) ──
              Positioned(
                top: topInset + 10,
                left: 74,
                right: 74,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.card.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.inkFaint),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          statusSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 4. Floating Top-Right Map Controls ──
              Positioned(
                top: topInset + 10,
                right: 14,
                child: Column(
                  children: [
                    HeroIconButton(
                      icon: Icons.my_location_rounded,
                      semanticLabel: 'Center on vehicle',
                      onPressed: _centreOnCar,
                    ),
                    const SizedBox(height: 10),
                    HeroIconButton(
                      icon: Icons.route_rounded,
                      semanticLabel: 'Fit entire route',
                      onPressed: _fitRoute,
                    ),
                    const SizedBox(height: 10),
                    HeroIconButton(
                      icon: Icons.add_rounded,
                      semanticLabel: 'Zoom in',
                      onPressed: () {
                        _mapController?.animateCamera(CameraUpdate.zoomIn());
                      },
                    ),
                    const SizedBox(height: 10),
                    HeroIconButton(
                      icon: Icons.remove_rounded,
                      semanticLabel: 'Zoom out',
                      onPressed: () {
                        _mapController?.animateCamera(CameraUpdate.zoomOut());
                      },
                    ),
                  ],
                ),
              ),

              // ── 5. Sliding Draggable Bottom Sheet ──
              DraggableScrollableSheet(
                initialChildSize: 0.44,
                minChildSize: 0.22,
                maxChildSize: 0.88,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 20,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(18, 10, 18, bottomInset + 20),
                      children: [
                        // Drag handle pill
                        Center(
                          child: Container(
                            width: 44,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: colors.inkFaint,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Title & Live GPS Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _step >= 2 ? 'Active Trip' : 'Trip Navigation',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: colors.ink,
                                letterSpacing: -0.4,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, size: 7, color: Color(0xFF10B981)),
                                  SizedBox(width: 5),
                                  Text(
                                    'Live GPS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ETA, Distance, Fare Summary Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.inkFaint),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF10B981)),
                                  const SizedBox(width: 6),
                                  Text(
                                    etaText,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.ink),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 16, color: colors.inkFaint),
                              Row(
                                children: [
                                  const Icon(Icons.straighten_rounded, size: 16, color: Color(0xFF3B82F6)),
                                  const SizedBox(width: 6),
                                  Text(
                                    distanceText,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.ink),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 16, color: colors.inkFaint),
                              Row(
                                children: [
                                  const Icon(Icons.payments_outlined, size: 16, color: AppTheme.brandDark),
                                  const SizedBox(width: 6),
                                  Text(
                                    '£${job.fare.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: colors.ink),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Action Button (Arrived at Pickup / Start Trip / Complete Trip)
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.brand,
                            foregroundColor: AppTheme.midnight,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (_step == 0) {
                              setState(() => _step = 1);
                              _centreOnCar();
                            } else if (_step == 1) {
                              setState(() => _step = 2);
                              // Smoothly drive along route from Central Station to The Avenue
                              _animateAlongWaypoints(_routePoints.sublist(0, 50));
                            } else {
                              // Smoothly drive to Southampton Airport Terminal
                              _animateAlongWaypoints(
                                _routePoints.sublist(49),
                                onComplete: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Trip completed successfully! Earnings added.')),
                                  );
                                  Navigator.of(context).pop();
                                },
                              );
                            }
                          },
                          child: Text(
                            actionButtonText,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Passenger Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.inkFaint),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppTheme.brand,
                                    child: Text(
                                      job.passengerName.isNotEmpty ? job.passengerName[0] : 'S',
                                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.midnight),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job.passengerName,
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.ink),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${job.passengersCount} Passengers • ${job.luggageCount} Bags',
                                          style: TextStyle(fontSize: 12, color: colors.inkMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.phone_outlined, size: 16),
                                      label: const Text('Call Passenger'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: colors.ink,
                                        side: BorderSide(color: colors.inkFaint),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                      label: const Text('Message'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: colors.ink,
                                        side: BorderSide(color: colors.inkFaint),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () {},
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Route Details Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.inkFaint),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Route Details',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colors.ink),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 3),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Pickup (Point A)', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                                        Text(job.pickupAddress, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink)),
                                        Text('4:30 PM', style: TextStyle(fontSize: 11.5, color: colors.inkMuted)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 7.5, top: 4, bottom: 4),
                                child: Container(width: 1.5, height: 16, color: colors.inkFaint),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 3),
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.brand.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.location_on_rounded, size: 10, color: AppTheme.brandDark),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Drop-off (Point B)', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                                        Text(job.destinationAddress, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink)),
                                        Text('5:00 PM (est.)', style: TextStyle(fontSize: 11.5, color: colors.inkMuted)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (job.flightNumber != null) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(color: colors.inkFaint, height: 1),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.flight_takeoff_rounded, size: 16, color: colors.inkMuted),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Flight: ${job.flightNumber}',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.ink),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Booking Reference
                        Center(
                          child: Text(
                            'Booking Ref: ${job.reference}',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: colors.inkMuted),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Helper: Custom Rotated Car Marker ──
  static Future<BitmapDescriptor> _createRotatedCarMarker(double pixelRatio, double bearing) async {
    const size = 64.0;
    final px = (size * pixelRatio).ceil();
    final py = (size * pixelRatio).ceil();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);

    const center = Offset(size / 2, size / 2);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Rotate canvas by bearing so the vehicle points straight along the road!
    canvas.rotate(bearing * math.pi / 180.0);
    _drawCleanCar(canvas, Offset.zero, 44);
    canvas.restore();

    final image = await recorder.endRecording().toImage(px, py);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: pixelRatio,
    );
  }

  static void _drawCleanCar(Canvas canvas, Offset center, double height) {
    final w = height * 0.48; // ~21px
    final h = height;        // ~44px
    final left = center.dx - w / 2;
    final top = center.dy - h / 2;

    // 1. Natural vehicle drop shadow (directly beneath the car shape)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final shadowRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top + 3, w, h),
      const Radius.circular(8),
    );
    canvas.drawRRect(shadowRRect, shadowPaint);

    // 2. Side Mirrors
    final mirrorPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left - 3, top + h * 0.28, 3.5, 6),
        const Radius.circular(1.5),
      ),
      mirrorPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + w - 0.5, top + h * 0.28, 3.5, 6),
        const Radius.circular(1.5),
      ),
      mirrorPaint,
    );

    // 3. Main Car Body (Brand Gold luxury vehicle)
    final bodyPaint = Paint()..color = AppTheme.brand;
    final bodyBorderPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, w, h),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);
    canvas.drawRRect(bodyRRect, bodyBorderPaint);

    // 4. Front Windshield (curved dark glass)
    final glassPaint = Paint()..color = const Color(0xFF0F172A);
    final windshield = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + 2.5, top + h * 0.22, w - 5, h * 0.16),
      const Radius.circular(4),
    );
    canvas.drawRRect(windshield, glassPaint);

    // 5. Rear Window
    final rearWindow = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + 3, top + h * 0.65, w - 6, h * 0.12),
      const Radius.circular(3),
    );
    canvas.drawRRect(rearWindow, glassPaint);

    // 6. Side Windows
    canvas.drawRect(
      Rect.fromLTWH(left + 2, top + h * 0.36, 1.8, h * 0.3),
      glassPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(left + w - 3.8, top + h * 0.36, 1.8, h * 0.3),
      glassPaint,
    );

    // 7. Dark Luxury Roof
    final roofRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + 3.5, top + h * 0.36, w - 7, h * 0.3),
      const Radius.circular(3),
    );
    canvas.drawRRect(roofRRect, Paint()..color = const Color(0xFF1E293B));

    // 8. Front Headlights (bright yellow LEDs facing UP)
    final lightPaint = Paint()..color = const Color(0xFFFEF08A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 2, top + 1, 3.5, 3),
        const Radius.circular(1),
      ),
      lightPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + w - 5.5, top + 1, 3.5, 3),
        const Radius.circular(1),
      ),
      lightPaint,
    );

    // 9. Rear Tail Lights (red LEDs facing DOWN)
    final tailPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 2, top + h - 3, 4, 2),
        const Radius.circular(1),
      ),
      tailPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + w - 6, top + h - 3, 4, 2),
        const Radius.circular(1),
      ),
      tailPaint,
    );
  }

  // ── Helper: Custom Point Marker (Destination Point B) ──
  static Future<BitmapDescriptor> _createPointMarker({
    required String label,
    required Color color,
    Color? borderColor,
    required double pixelRatio,
  }) async {
    const size = 44.0;
    final px = (size * pixelRatio).ceil();
    final py = (size * pixelRatio).ceil();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);

    const center = Offset(size / 2, size / 2);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center.translate(0, 2), 17, shadowPaint);

    canvas.drawCircle(center, 17, Paint()..color = borderColor ?? Colors.white);
    canvas.drawCircle(center, 14.5, Paint()..color = color);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          fontFamily: 'Figtree',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));

    final image = await recorder.endRecording().toImage(px, py);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: pixelRatio,
    );
  }
}

/// Dark Map Theme Styling (matches booking map)
const _darkMapStyle = '''
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
