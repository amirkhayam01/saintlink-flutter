import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/common.dart';
import '../../../widgets/tiles.dart';

/// The four things the company does, as a 2×2 grid of [ServiceTile]s. Each
/// presets the journey form with a sensible destination.
class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key, required this.onSelectService});

  final void Function(String serviceName, String? defaultDropoff)
  onSelectService;

  static const _services = [
    (
      title: 'Airport transfers',
      caption: 'Meet & greet',
      icon: Icons.flight_takeoff_rounded,
      route: '/services/airport',
      dest: null,
    ),
    (
      title: 'Cruise terminals',
      caption: 'Door to ship',
      icon: Icons.directions_boat_filled_rounded,
      route: '/services/cruise',
      dest: null,
    ),
    (
      title: 'Private hire',
      caption: 'Any journey',
      icon: Icons.directions_car_rounded,
      route: null,
      dest: null,
    ),
    (
      title: 'Routes & prices',
      caption: 'Popular fixed fares',
      icon: Icons.sell_outlined,
      route: '/prices',
      dest: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Our services'),
        const SizedBox(height: 12),
        for (var row = 0; row < _services.length; row += 2) ...[
          if (row > 0) const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) const SizedBox(width: 10),
                  Expanded(
                    child: ServiceTile(
                      icon: _services[row + col].icon,
                      title: _services[row + col].title,
                      caption: _services[row + col].caption,
                      onTap: () {
                        final service = _services[row + col];
                        if (service.route != null) {
                          context.push(service.route!);
                        } else {
                          onSelectService(service.title, service.dest);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
