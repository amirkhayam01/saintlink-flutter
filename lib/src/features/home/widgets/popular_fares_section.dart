import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Popular fixed fares direct from the Saints Link website.
class PopularFaresSection extends StatelessWidget {
  const PopularFaresSection({super.key, required this.onSelectFare});

  final void Function(String from, String to) onSelectFare;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final fares = [
      (
        from: 'Southampton',
        to: 'Heathrow Airport (LHR)',
        price: '£115',
        detail: 'Fixed price agreed upfront',
      ),
      (
        from: 'Southampton',
        to: 'Cruise Terminals (Port)',
        price: '£35',
        detail: 'Direct pier & baggage drop',
      ),
      (
        from: 'Southampton',
        to: 'Gatwick Airport (LGW)',
        price: '£125',
        detail: 'Terminal meet & greet',
      ),
      (
        from: 'Southampton',
        to: 'Central London',
        price: '£165',
        detail: 'Intercity executive transfer',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'POPULAR FIXED FARES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.brandDark,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'No surprise meter rates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 165,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: fares.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final fare = fares[index];

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelectFare(fare.from, fare.to),
                child: Container(
                  width: 270,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.inkFaint),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.brand.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'FIXED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.brandDark,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Text(
                              'From ${fare.price}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: colors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '${fare.from} → ${fare.to}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fare.detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.inkMuted,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            'Book now',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.brandDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 12, color: AppTheme.brandDark),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Executive fleet preview carousel.
