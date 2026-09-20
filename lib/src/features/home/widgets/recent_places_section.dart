import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../domain/place.dart';
import '../../places/recent_places.dart';
import 'home_section_heading.dart';

/// The places this customer keeps going back to, one tap from the front door.
///
/// Airport work repeats in a way city hailing does not: the same house to the
/// same terminal, a few times a year. Those journeys were already remembered —
/// [recentPlacesProvider] has kept the last few on the device all along — but
/// they only appeared once the address field was opened, which is one screen
/// and one tap too late to save anyone anything.
///
/// With no history yet there is nothing to show and the section stays out of
/// the way: the chip row above already offers every shortcut, and repeating
/// the same four airports as a list directly beneath it would be a copy, not
/// a convenience.
class RecentPlacesSection extends ConsumerWidget {
  const RecentPlacesSection({
    super.key,
    required this.onSelect,
    this.spacingBelow = 0,
  });

  final ValueChanged<PlaceSelection> onSelect;
  final double spacingBelow;

  /// Long enough to be worth scanning, short enough not to push the rest of
  /// the screen below the fold.
  static const _maxRows = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(goAgainPlacesProvider).take(_maxRows).toList();

    if (places.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HomeSectionHeading('Go again'),
        const SizedBox(height: 4),
        for (final place in places)
          _PlaceRow(place: place, onTap: () => onSelect(place)),
        SizedBox(height: spacingBelow),
      ],
    );
  }
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({required this.place, required this.onTap});

  final PlaceSelection place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Icon(Icons.history_rounded, size: 20, color: colors.inkMuted),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                place.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.ink,
                ),
              ),
            ),
            Icon(Icons.north_east_rounded, size: 16, color: colors.inkMuted),
          ],
        ),
      ),
    );
  }
}
