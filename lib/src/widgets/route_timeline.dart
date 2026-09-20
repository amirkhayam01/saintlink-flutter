import 'package:flutter/material.dart';

import '../core/theme.dart';

/// One point on a route, as the timeline draws it.
class RoutePoint {
  const RoutePoint({required this.address, this.label, this.detail});

  final String address;

  /// Small caption above the address, e.g. "PICKUP" or "THU 1 OCT · 09:00".
  final String? label;

  /// Secondary line under the address, e.g. a flight number.
  final String? detail;
}

/// Pickup, stops and destination joined by a line; the one drawing of a journey everywhere.
class RouteTimeline extends StatelessWidget {
  const RouteTimeline({super.key, required this.points, this.dense = false});

  final List<RoutePoint> points;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < points.length; i++)
          _Row(
            point: points[i],
            first: i == 0,
            last: i == points.length - 1,
            dense: dense,
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.point,
    required this.first,
    required this.last,
    required this.dense,
  });

  final RoutePoint point;
  final bool first;
  final bool last;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                SizedBox(
                  height: dense ? 4 : 6,
                  child: first ? null : _Line(colors.inkFaint),
                ),
                _Marker(first: first, last: last),
                Expanded(
                  child: last ? const SizedBox() : _Line(colors.inkFaint),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : (dense ? 10 : 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (point.label != null)
                    Text(
                      point.label!.toUpperCase(),
                      style: TextStyle(
                        color: colors.inkMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  Text(
                    point.address,
                    style: TextStyle(
                      fontSize: dense ? 14 : 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  if (point.detail != null)
                    Text(
                      point.detail!,
                      style: TextStyle(color: colors.inkMuted, fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.first, required this.last});

  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final ink = context.colors.ink;
    if (first) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ink, width: 2.5),
        ),
      );
    }
    if (last) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: AppTheme.brand,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: ink, width: 2),
        ),
      );
    }

    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.inkMuted,
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Center(child: Container(width: 2, color: color));
}
