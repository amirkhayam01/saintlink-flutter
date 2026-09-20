import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum JourneyMarkerKind { pickup, stop, dropoff }

/// A marker bitmap and where on it the map point sits.
class JourneyMarker {
  const JourneyMarker({required this.icon, required this.anchor});

  final BitmapDescriptor icon;
  final Offset anchor;
}

/// The map's pins, the way the ride apps draw them: a badge on a stem above
/// the exact point, with the place name in a pill beside it. Ink and white
/// only; the symbol in the badge matches [RouteTimeline]. Rendered once per
/// label and pixel ratio, and cached.
class JourneyMarkers {
  JourneyMarkers._();

  static final _cache = <String, JourneyMarker>{};

  static const _badge = 30.0;
  static const _stem = 10.0;
  static const _dot = 3.5;
  static const _margin = 6.0;
  static const _maxLabelChars = 30;

  static Future<JourneyMarker> of(
    JourneyMarkerKind kind, {
    required double pixelRatio,
    required Color ink,
    required Color onInk,
    required Color card,
    required Color onCard,
    String? label,
  }) async {
    final text = _shorten(label);
    final key =
        '${kind.name}:$pixelRatio:${ink.toARGB32()}:${card.toARGB32()}:$text';
    final cached = _cache[key];
    if (cached != null) return cached;

    final small = kind == JourneyMarkerKind.stop;
    final badge = small ? 22.0 : _badge;

    final painter = text == null
        ? null
        : (TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: onCard,
                fontFamily: 'Figtree',
              ),
            ),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout());

    final pillW = painter == null ? 0.0 : painter.width + 20;
    final pillH = 26.0;
    final width = _margin * 2 + badge + (painter == null ? 0 : 6 + pillW);
    final height = _margin * 2 + badge + _stem + _dot * 2;
    final px = (width * pixelRatio).ceil();
    final py = (height * pixelRatio).ceil();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(_margin, _margin, badge, badge),
      Radius.circular(small ? 6 : 8),
    );
    final cx = _margin + badge / 2;
    final stemTop = _margin + badge;
    final dotY = stemTop + _stem + _dot;

    // Stem and dot first, so the badge sits over the stem's top.
    canvas.drawCircle(Offset(cx, dotY + 1), _dot, shadow);
    canvas.drawLine(
      Offset(cx, stemTop),
      Offset(cx, dotY),
      Paint()
        ..color = ink
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(cx, dotY), _dot + 1.5, Paint()..color = onInk);
    canvas.drawCircle(Offset(cx, dotY), _dot, Paint()..color = ink);

    canvas.drawRRect(badgeRect.shift(const Offset(0, 2)), shadow);
    canvas.drawRRect(badgeRect, Paint()..color = ink);

    final c = Offset(cx, _margin + badge / 2);
    switch (kind) {
      case JourneyMarkerKind.pickup:
        canvas.drawCircle(
          c,
          6,
          Paint()
            ..color = onInk
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      case JourneyMarkerKind.stop:
        canvas.drawCircle(c, 3.5, Paint()..color = onInk);
      case JourneyMarkerKind.dropoff:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: 11, height: 11),
            const Radius.circular(2.5),
          ),
          Paint()..color = onInk,
        );
    }

    if (painter != null) {
      final pill = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          _margin + badge + 6,
          _margin + (badge - pillH) / 2,
          pillW,
          pillH,
        ),
        Radius.circular(pillH / 2),
      );
      canvas.drawRRect(pill.shift(const Offset(0, 2)), shadow);
      canvas.drawRRect(pill, Paint()..color = card);
      painter.paint(
        canvas,
        Offset(pill.left + 10, pill.top + (pillH - painter.height) / 2),
      );
    }

    final image = await recorder.endRecording().toImage(px, py);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    final marker = JourneyMarker(
      icon: BitmapDescriptor.bytes(
        bytes!.buffer.asUint8List(),
        imagePixelRatio: pixelRatio,
      ),
      // The map point is the dot at the foot of the stem.
      anchor: Offset(cx / width, dotY / height),
    );
    _cache[key] = marker;

    return marker;
  }

  /// The first line of an address, cut to fit a pill.
  static String? _shorten(String? label) {
    if (label == null) return null;
    final first = label.split(',').first.trim();
    if (first.isEmpty) return null;
    return first.length <= _maxLabelChars
        ? first
        : '${first.substring(0, _maxLabelChars - 1).trimRight()}…';
  }
}
