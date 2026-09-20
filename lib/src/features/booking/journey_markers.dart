import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


enum JourneyMarkerKind { pickup, stop, dropoff }

/// The map's pins, in ink only: a ring for the pickup, a filled square for
/// the destination, a dot for a stop. Rendered once per pixel ratio and cached.
class JourneyMarkers {
  JourneyMarkers._();

  static final _cache = <String, BitmapDescriptor>{};

  static Future<BitmapDescriptor> of(
    JourneyMarkerKind kind, {
    required double pixelRatio,
    required Color ink,
    required Color muted,
  }) async {
    final key = '${kind.name}:$pixelRatio:${ink.toARGB32()}:${muted.toARGB32()}';
    final cached = _cache[key];
    if (cached != null) return cached;

    const size = 30.0;
    final px = (size * pixelRatio).round();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);
    const c = Offset(size / 2, size / 2);

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    switch (kind) {
      case JourneyMarkerKind.pickup:
        canvas.drawCircle(c.translate(0, 1.5), 9, shadow);
        canvas.drawCircle(c, 9, Paint()..color = Colors.white);
        canvas.drawCircle(
          c,
          9,
          Paint()
            ..color = ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5,
        );
      case JourneyMarkerKind.stop:
        canvas.drawCircle(c.translate(0, 1), 6, shadow);
        canvas.drawCircle(c, 6, Paint()..color = Colors.white);
        canvas.drawCircle(c, 4.5, Paint()..color = muted);
      case JourneyMarkerKind.dropoff:
        final rect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: c, width: 18, height: 18),
          const Radius.circular(4),
        );
        canvas.drawRRect(rect.shift(const Offset(0, 1.5)), shadow);
        canvas.drawRRect(rect, Paint()..color = ink);
        canvas.drawRRect(
          rect,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
    }

    final image = await recorder.endRecording().toImage(px, px);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    final descriptor = BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: pixelRatio,
    );
    _cache[key] = descriptor;

    return descriptor;
  }
}
