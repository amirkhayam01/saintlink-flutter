import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lets a native map be pumped in a widget test.
///
/// `GoogleMap` is a platform view, and there is no platform under a widget
/// test. Two channels want answering before the widget settles: the
/// platform-views channel, where `create` must return a view id, and the
/// map's own method channel, where `map#waitForMap`, `camera#move` and the
/// rest are content with no reply. With both answered the map mounts, lays
/// out and draws its blank surface like any other widget, so the screens
/// around it can be tested and shot.
///
/// No native plugin registers in a test, so the platform interface's default
/// `MethodChannel` implementation is what runs, one channel per map with the
/// map's id as a suffix. Ids count up across the test process, so a run of
/// them is registered up front.
void stubPlatformViews() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  messenger.setMockMethodCallHandler(SystemChannels.platform_views, (call) async {
    return switch (call.method) {
      'create' => 0,
      _ => null,
    };
  });

  for (var mapId = 0; mapId < 64; mapId++) {
    messenger.setMockMethodCallHandler(
      MethodChannel('plugins.flutter.io/google_maps_$mapId'),
      (_) async => null,
    );
  }
}
