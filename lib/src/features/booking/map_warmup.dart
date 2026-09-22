import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A one-pixel map mounted behind the shell at launch. The first map a
/// session creates pays for the renderer's start-up; this pays it while the
/// splash is still showing, so the booking form's map appears at once.
///
/// It waits for the first frame to be on screen first: the launch screen
/// stays up until that frame, and creating the map inside it would keep the
/// person on a blank launch screen instead of the splash.
class MapWarmup extends StatefulWidget {
  const MapWarmup({super.key});

  @override
  State<MapWarmup> createState() => _MapWarmupState();
}

class _MapWarmupState extends State<MapWarmup> {
  var _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.waitUntilFirstFrameRasterized.then((_) {
      // A beat later, so the splash's entrance is not the frame that pays.
      return Future<void>.delayed(const Duration(milliseconds: 250));
    }).then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();
    return const Positioned(
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
}
