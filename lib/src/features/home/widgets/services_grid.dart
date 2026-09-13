import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Service selector cards matching the website's service pillars.
class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key, required this.onSelectService});

  final void Function(String serviceName, String? defaultDropoff) onSelectService;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final services = [
      (
        title: 'Airport Transfer',
        subtitle: 'Meet & greet + flight track',
        icon: Icons.flight_takeoff_rounded,
        dest: 'London Heathrow Airport (LHR)',
      ),
      (
        title: 'Cruise Terminal',
        subtitle: 'Luggage assist & port drop',
        icon: Icons.directions_boat_filled_rounded,
        dest: 'Southampton Cruise Terminals',
      ),
      (
        title: 'By the Hour',
        subtitle: 'Dedicated chauffeur hire',
        icon: Icons.schedule_rounded,
        dest: null,
      ),
      (
        title: 'Long Distance',
        subtitle: 'Intercity premium travel',
        icon: Icons.route_rounded,
        dest: 'Central London, UK',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.ink,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            for (final s in services)
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelectService(s.title, s.dest),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.inkFaint),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.brand.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(s.icon, size: 18, color: AppTheme.brandDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                      Text(
                        s.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Popular fixed fares direct from the Saints Link website.
