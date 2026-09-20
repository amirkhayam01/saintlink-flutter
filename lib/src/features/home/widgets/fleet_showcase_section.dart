import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../widgets/tiles.dart';
import '../../../domain/vehicle_category.dart';
import '../../../widgets/common.dart';
import '../../../widgets/vehicle_image.dart';

/// The fleet as a carousel of photo cards. Tapping one presets that vehicle
/// on the journey form.
class FleetShowcaseSection extends StatelessWidget {
  const FleetShowcaseSection({
    super.key,
    required this.vehicles,
    required this.onSelectVehicle,
    this.gutter = 18,
  });

  final List<VehicleCategory> vehicles;
  final ValueChanged<VehicleCategory> onSelectVehicle;
  final double gutter;

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: const SectionTitle('Our fleet'),
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
                for (final (index, vehicle) in vehicles.indexed) ...[
                  if (index > 0) const SizedBox(width: 12),
                  _FleetCard(
                    vehicle: vehicle,
                    onTap: () => onSelectVehicle(vehicle),
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

class _FleetCard extends StatelessWidget {
  const _FleetCard({required this.vehicle, required this.onTap});

  final VehicleCategory vehicle;
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
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.inkFaint),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 108,
                  width: double.infinity,
                  child: VehicleImage(vehicle.slug),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: colors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 14,
                              runSpacing: 6,
                              children: [
                                CapacityChip(
                                  icon: Icons.person_outline_rounded,
                                  count: vehicle.passengerCapacity,
                                  label: 'passengers',
                                ),
                                CapacityChip(
                                  icon: Icons.luggage_outlined,
                                  count: vehicle.luggageCapacity,
                                  label: 'large suitcases',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: colors.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
