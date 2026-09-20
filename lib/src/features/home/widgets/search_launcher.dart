import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../domain/place.dart';
import '../../places/place_autocomplete_field.dart';
import '../../places/recent_places.dart';

/// The "Where can we take you?" bar and the shortcut chips. Applies its own [gutter] so the chips can bleed to the edge.
class SearchLauncher extends StatelessWidget {
  const SearchLauncher({
    super.key,
    required this.onSelectPlace,
    required this.onSelectHub,
    this.gutter = 18,
  });

  final ValueChanged<PlaceSelection> onSelectPlace;
  final ValueChanged<PlaceSelection> onSelectHub;
  final double gutter;

  // The chips are `shortcutPlaces` itself, so the server's names are the only spelling.
  static const _hubIcon = Icons.flight_takeoff_rounded;

  /// IATA codes for the chip labels; they belong to the airport, not the place.
  static const _codes = {
    'Heathrow Airport': 'LHR',
    'Gatwick Airport': 'LGW',
    'Southampton Airport': 'SOU',
    'Bournemouth Airport': 'BOH',
    'London Stansted Airport': 'STN',
  };

  static String _chipLabel(PlaceSelection place) {
    final short = place.address
        .replaceAll('London ', '')
        .replaceAll(' Airport', '')
        .replaceAll(' Terminals', '');
    final code = _codes[place.address];

    return code == null ? short : '$short ($code)';
  }

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
              for (final (i, hub) in shortcutPlaces.indexed)
                Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                  child: ActionChip(
                    avatar: Icon(_hubIcon, size: 16, color: colors.accent),
                    label: Text(_chipLabel(hub)),
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
                    onPressed: () => onSelectHub(hub),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
