import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A one-pixel map mounted behind the shell at launch. The first map a
/// session creates pays for the renderer's start-up; this pays it while the
/// splash is still showing, so the booking form's map appears at once.
class MapWarmup extends StatelessWidget {
  const MapWarmup({super.key});

  @override
  Widget build(BuildContext context) => const Positioned(
    left: 0,
    top: 0,
    width: 1,
    height: 1,
    child: IgnorePointer(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(50.9097, -1.4044),
          zoom: 10,
        ),
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
        myLocationButtonEnabled: false,
      ),
    ),
  );
}
