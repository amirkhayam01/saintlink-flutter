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

/// The map's pins: a round badge on a stem for the pickup and stops, a
/// teardrop pin for the destination, the place name in a pill beside each.
/// Ink and white only. Rendered once per label and pixel ratio, and cached.
class JourneyMarkers {
  JourneyMarkers._();

  static final _cache = <String, JourneyMarker>{};

  static const _badge = 30.0;
  static const _stem = 10.0;
  static const _dot = 3.5;
  static const _margin = 6.0;
  static const _maxLabelChars = 30;

  /// How far the teardrop's tip sits below its circle's centre.
  static const _pinDrop = 24.0;

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
    final pin = kind == JourneyMarkerKind.dropoff;
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
    // A pin's tip reaches further down than a badge's stem and dot.
    final below = pin ? _pinDrop - badge / 2 : _stem + _dot * 2;
    final height = _margin * 2 + badge + below;
    final px = (width * pixelRatio).ceil();
    final py = (height * pixelRatio).ceil();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final cx = _margin + badge / 2;
    final c = Offset(cx, _margin + badge / 2);
    final r = badge / 2;
    final double pointY;

    if (pin) {
      // Teardrop: the circle, and a tip hanging from its lower tangents.
      final tip = Offset(cx, c.dy + _pinDrop);
      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(cx - r * 0.72, c.dy + r * 0.69)
        ..arcToPoint(
          Offset(cx + r * 0.72, c.dy + r * 0.69),
          radius: Radius.circular(r),
          largeArc: true,
        )
        ..close();
      canvas.drawPath(path.shift(const Offset(0, 2)), shadow);
      canvas.drawPath(path, Paint()..color = ink);
      canvas.drawCircle(c, r * 0.36, Paint()..color = onInk);
      pointY = tip.dy;
    } else {
      final stemTop = c.dy + r;
      pointY = stemTop + _stem + _dot;
      canvas.drawCircle(Offset(cx, pointY + 1), _dot, shadow);
      canvas.drawLine(
        Offset(cx, stemTop),
        Offset(cx, pointY),
        Paint()
          ..color = ink
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(Offset(cx, pointY), _dot + 1.5, Paint()..color = onInk);
      canvas.drawCircle(Offset(cx, pointY), _dot, Paint()..color = ink);
      canvas.drawCircle(c.translate(0, 2), r, shadow);
      canvas.drawCircle(c, r, Paint()..color = ink);
      canvas.drawCircle(c, small ? 3.5 : r * 0.36, Paint()..color = onInk);
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
      // The map point is the dot at the foot of the stem, or the pin's tip.
      anchor: Offset(cx / width, pointY / height),
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
