import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Trust promises band inspired by config('company.policies') on website.
class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    const items = [
      (
        icon: Icons.verified_outlined,
        title: 'Fixed Price',
        desc: 'Agreed before travel',
      ),
      (
        icon: Icons.airplanemode_active_rounded,
        title: 'Flight Tracked',
        desc: 'Pickup adjusts for delays',
      ),
      (
        icon: Icons.badge_outlined,
        title: 'Licensed Drivers',
        desc: 'Professional local service',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.inkFaint),
        ),
        child: Row(
          children: [
            for (final item in items)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.brand.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: AppTheme.brandDark, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: colors.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.desc,
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.inkMuted,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
