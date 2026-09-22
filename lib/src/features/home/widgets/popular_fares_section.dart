import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../widgets/common.dart';

/// Popular fixed fares from the website, as a carousel of cards. Tapping one
/// presets the journey form with that route.
class PopularFaresSection extends StatelessWidget {
  const PopularFaresSection({
    super.key,
    required this.onSelectFare,
    this.gutter = 18,
  });

  final void Function(String from, String to) onSelectFare;
  final double gutter;

  static const _fares = [
    (
      from: 'Southampton',
      to: 'Heathrow Airport',
      code: 'LHR',
      address: 'London Heathrow Airport (LHR)',
      price: '£115',
      detail: 'Meet & greet in arrivals',
      icon: Icons.flight_takeoff_rounded,
    ),
    (
      from: 'Southampton',
      to: 'Cruise terminals',
      code: 'Port',
      address: 'Southampton Cruise Terminals',
      price: '£35',
      detail: 'Direct to your pier',
      icon: Icons.directions_boat_rounded,
    ),
    (
      from: 'Southampton',
      to: 'Gatwick Airport',
      code: 'LGW',
      address: 'London Gatwick Airport (LGW)',
      price: '£125',
      detail: 'Meet & greet in arrivals',
      icon: Icons.flight_takeoff_rounded,
    ),
    (
      from: 'Southampton',
      to: 'Central London',
      code: '',
      address: 'Central London, UK',
      price: '£165',
      detail: 'Door to door',
      icon: Icons.apartment_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: const SectionTitle('Popular destinations'),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, fare) in _fares.indexed) ...[
                  if (index > 0) const SizedBox(width: 12),
                  _FareCard(
                    from: fare.from,
                    to: fare.to,
                    code: fare.code,
                    price: fare.price,
                    detail: fare.detail,
                    icon: fare.icon,
                    onTap: () => onSelectFare('${fare.from}, UK', fare.address),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FareCard extends StatelessWidget {
  const _FareCard({
    required this.from,
    required this.to,
    required this.code,
    required this.price,
    required this.detail,
    required this.icon,
    required this.onTap,
  });

  final String from;
  final String to;
  final String code;
  final String price;
  final String detail;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: 236,
      child: Material(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.inkFaint),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: colors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'From $from',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: colors.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: to,
                    children: [
                      if (code.isNotEmpty)
                        TextSpan(
                          text: '  $code',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: colors.inkMuted,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: colors.inkMuted,
                  ),
                ),
                const SizedBox(height: 16),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'from ',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.inkMuted,
                          ),
                          children: [
                            TextSpan(
                              text: price,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: colors.ink,
                              ),
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 12, height: 1.2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: colors.accent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
