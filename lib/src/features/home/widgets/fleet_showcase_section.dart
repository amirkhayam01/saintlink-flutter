import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../domain/vehicle_category.dart';
import '../../../widgets/vehicle_image.dart';

/// Executive fleet preview carousel.
class FleetShowcaseSection extends StatelessWidget {
  const FleetShowcaseSection({super.key, required this.vehicles, required this.onSelectVehicle});

  final List<VehicleCategory> vehicles;
  final ValueChanged<VehicleCategory> onSelectVehicle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (vehicles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Our Executive Fleet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.ink,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 204,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: vehicles.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final v = vehicles[index];

              return Container(
                width: 220,
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.inkFaint),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 114,
                      width: double.infinity,
                      child: VehicleImage(v.slug),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 14, color: colors.inkMuted),
                              Text(' ${v.passengerCapacity}', style: TextStyle(fontSize: 12, color: colors.inkMuted)),
                              const SizedBox(width: 10),
                              Icon(Icons.luggage_outlined, size: 14, color: colors.inkMuted),
                              Text(' ${v.luggageCapacity}', style: TextStyle(fontSize: 12, color: colors.inkMuted)),
                              const Spacer(),
                              InkWell(
                                onTap: () => onSelectVehicle(v),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.brand.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Select',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.brandDark,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Trust promises band inspired by config('company.policies') on website.
