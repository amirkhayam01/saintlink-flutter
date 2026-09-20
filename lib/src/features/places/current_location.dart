import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Why a position could not be had. Each one is something the screen says
/// differently, so they are named rather than folded into one failure.
enum LocationDenial {
  /// Location is switched off on the device altogether.
  servicesOff,

  /// Refused this time. Asking again on the next tap is allowed.
  denied,

  /// Refused for good, or by policy. Only the system settings can change it
  /// now, so the screen offers to open them rather than asking again.
  deniedForever,

  /// The device could not produce a fix in time.
  unavailable,
}

class LocationDeniedException implements Exception {
  const LocationDeniedException(this.denial);

  final LocationDenial denial;
}

/// A position on the ground, and nothing else — the address is the server's
/// business.
class LocationFix {
  const LocationFix({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

/// Where the phone is right now. Asked for on a tap, never watched, never prompted at launch.
abstract class LocationSource {
  Future<LocationFix> current();

  /// A check, never a prompt; the maps use it for the location dot.
  Future<bool> isGranted();

  /// Sends the customer to the system settings page for this app, for the
  /// case where the permission can no longer be asked for in-app.
  Future<void> openSettings();
}

class GeolocatorLocationSource implements LocationSource {
  const GeolocatorLocationSource();

  @override
  Future<LocationFix> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationDeniedException(LocationDenial.servicesOff);
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    switch (permission) {
      case LocationPermission.denied:
        throw const LocationDeniedException(LocationDenial.denied);
      case LocationPermission.deniedForever:
      case LocationPermission.unableToDetermine:
        throw const LocationDeniedException(LocationDenial.deniedForever);
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        break;
    }

    try {
      // Best accuracy for a house-level pickup; the time limit stops a hang under no sky.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 12),
        ),
      );

      return LocationFix(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on LocationDeniedException {
      rethrow;
    } catch (_) {
      throw const LocationDeniedException(LocationDenial.unavailable);
    }
  }

  @override
  Future<bool> isGranted() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;
      final permission = await Geolocator.checkPermission();

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> openSettings() => Geolocator.openAppSettings();
}

final locationSourceProvider = Provider<LocationSource>(
  (ref) => const GeolocatorLocationSource(),
);

/// Whether the maps may show where the customer is. Re-read after a grant,
/// so the dot appears on the very next map without a restart.
final locationGrantedProvider = FutureProvider<bool>(
  (ref) => ref.watch(locationSourceProvider).isGranted(),
);
