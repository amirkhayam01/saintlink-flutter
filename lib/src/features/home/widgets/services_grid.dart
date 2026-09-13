import 'package:flutter/material.dart';

import '../../../widgets/common.dart';
import '../../../widgets/tiles.dart';

/// The four things the company does, as a 2×2 grid of [ServiceTile]s. Each
/// presets the journey form with a sensible destination.
class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key, required this.onSelectService});

  final void Function(String serviceName, String? defaultDropoff) onSelectService;

  static const _services = [
    (title: 'Airport transfers', caption: 'Meet & greet', icon: Icons.flight_takeoff_rounded, dest: 'London Heathrow Airport (LHR)'),
    (title: 'Cruise terminals', caption: 'Door to ship', icon: Icons.directions_boat_filled_rounded, dest: 'Southampton Cruise Terminals'),
    (title: 'Private hire', caption: 'Any journey', icon: Icons.directions_car_rounded, dest: null),
    (title: 'Long distance', caption: 'London & beyond', icon: Icons.route_rounded, dest: 'Central London, UK'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Our services'),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            for (final s in _services)
              ServiceTile(
                icon: s.icon,
                title: s.title,
                caption: s.caption,
                onTap: () => onSelectService(s.title, s.dest),
              ),
          ],
        ),
      ],
    );
  }
}
