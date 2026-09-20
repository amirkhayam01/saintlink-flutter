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

/// Where the phone is right now.
///
/// One method, on purpose: the app never watches location, only asks for it
/// on a tap. Foreground permission only, requested at that moment and not
/// before — a prompt on launch is the one most people refuse, and on iOS a
/// refusal is close to permanent.
abstract class LocationSource {
  Future<LocationFix> current();

  /// Whether the app may already read location — a check, never a prompt.
  ///
  /// The route maps use it to decide whether to draw the "you are here" dot.
  /// A customer who has once tapped "Use my current location" gets the dot
  /// from then on; nobody is asked for anything on a screen with no reason
  /// to ask.
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
      /*
       * A pickup address wants the house, not the street, so this asks for
       * the best the device will give. The time limit is what stops a phone
       * with no sky view from hanging the sheet: past it, the customer is
       * told and can type instead.
       */
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 12),
        ),
      );

      return LocationFix(latitude: position.latitude, longitude: position.longitude);
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
