import 'package:flutter/material.dart';

import '../../../widgets/tiles.dart';

/// The three promises the website makes on every page, as a [BadgeRow].
class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return const BadgeRow(
      items: [
        (icon: Icons.verified_outlined, label: 'Fixed price', caption: 'Agreed before travel'),
        (icon: Icons.airplanemode_active_rounded, label: 'Flight tracked', caption: 'Pickup moves with delays'),
        (icon: Icons.badge_outlined, label: 'Licensed drivers', caption: 'Professional, local'),
      ],
    );
  }
}
