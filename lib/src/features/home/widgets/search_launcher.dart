import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Instant "Where can we take you?" search bar and popular UK destination chips.
class SearchLauncher extends StatelessWidget {
  const SearchLauncher({super.key, required this.onTap, required this.onSelectHub});

  final VoidCallback onTap;
  final void Function(String name, String address) onSelectHub;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hubs = [
      (label: 'Heathrow (LHR)', icon: Icons.flight_takeoff_rounded, address: 'London Heathrow Airport (LHR)'),
      (label: 'Cruise Terminal', icon: Icons.directions_boat_rounded, address: 'Southampton Cruise Terminals'),
      (label: 'Gatwick (LGW)', icon: Icons.flight_takeoff_rounded, address: 'London Gatwick Airport (LGW)'),
      (label: 'Central London', icon: Icons.apartment_rounded, address: 'Central London, UK'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 22, color: AppTheme.brandDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Where can we take you?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.inkMuted,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.brand : AppTheme.midnight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Book',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.midnight : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: isDark ? AppTheme.midnight : Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (final hub in hubs)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Icon(hub.icon, size: 15, color: isDark ? AppTheme.brand : AppTheme.midnight),
                    label: Text(
                      hub.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.ink,
                      ),
                    ),
                    backgroundColor: colors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colors.inkFaint),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    onPressed: () => onSelectHub(hub.label, hub.address),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Service selector cards matching the website's service pillars.
