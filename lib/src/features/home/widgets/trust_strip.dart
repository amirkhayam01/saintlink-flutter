import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// A compact panel that explains the promises without oversized icon badges.
class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  static const _items = [
    (
      icon: Icons.sell_outlined,
      title: 'Fixed price',
      detail: 'Agreed before you travel.',
    ),
    (
      icon: Icons.flight_rounded,
      title: 'Flight tracked',
      detail: 'Pickup adjusts to flight delays.',
    ),
    (
      icon: Icons.verified_user_outlined,
      title: 'Licensed drivers',
      detail: 'Professional drivers who know the area.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.tint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Travel with confidence',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.ink,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_items[i].icon, size: 21, color: colors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _items[i].title,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _items[i].detail,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
