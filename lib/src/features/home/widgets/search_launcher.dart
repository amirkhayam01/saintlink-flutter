import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../domain/place.dart';
import '../../places/place_autocomplete_field.dart';

/// The "Where can we take you?" bar that opens the booking form, with a row
/// of popular destinations under it that preset the form in one tap.
///
/// The chip row scrolls edge to edge, so the launcher takes the screen's
/// [gutter] and applies it itself rather than living inside a padded column.
class SearchLauncher extends StatelessWidget {
  const SearchLauncher({
    super.key,
    required this.onSelectPlace,
    required this.onSelectHub,
    this.gutter = 18,
  });

  final ValueChanged<PlaceSelection> onSelectPlace;
  final void Function(String name, String address) onSelectHub;
  final double gutter;

  static const _hubs = [
    (
      label: 'Heathrow (LHR)',
      icon: Icons.flight_takeoff_rounded,
      address: 'London Heathrow Airport (LHR)',
    ),
    (
      label: 'Gatwick (LGW)',
      icon: Icons.flight_takeoff_rounded,
      address: 'London Gatwick Airport (LGW)',
    ),
    (
      label: 'Southampton (SOU)',
      icon: Icons.flight_takeoff_rounded,
      address: 'Southampton Airport (SOU)',
    ),
    (
      label: 'Bournemouth (BOH)',
      icon: Icons.flight_takeoff_rounded,
      address: 'Bournemouth Airport (BOH)',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: PlaceAutocompleteField(onSelected: onSelectPlace),
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: Row(
            children: [
              for (final (i, hub) in _hubs.indexed)
                Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                  child: ActionChip(
                    avatar: Icon(hub.icon, size: 16, color: colors.accent),
                    label: Text(hub.label),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                    backgroundColor: colors.card,
                    side: BorderSide(color: colors.inkFaint),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
