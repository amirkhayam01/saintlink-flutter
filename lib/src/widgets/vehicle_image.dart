import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The photo for a vehicle class, bundled with the app.
///
/// Bundled rather than fetched from the site: the fleet is five images that
/// change once a year, and a card with a photo that pops in late looks
/// cheaper than one that was never there. The slug is the file name.
class VehicleImage extends StatelessWidget {
  const VehicleImage(this.slug, {super.key, this.fit = BoxFit.cover});

  final String slug;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/vehicles/$slug-v1.webp',
      fit: fit,
      errorBuilder: (context, _, _) => Container(
        color: context.colors.inkFaint,
        alignment: Alignment.center,
        child: Icon(Icons.directions_car_outlined, color: context.colors.inkMuted, size: 32),
      ),
    );
  }
}
