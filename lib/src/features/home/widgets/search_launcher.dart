import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../domain/place.dart';
import '../../places/place_autocomplete_field.dart';
import '../../places/recent_places.dart';

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
  final ValueChanged<PlaceSelection> onSelectHub;
  final double gutter;

  /*
   * The chips are the shortcut list itself rather than a second copy of it.
   * They used to carry a hand-written label and a bare address string, which
   * arrived at the pricing engine with no coordinates: `isLocated` false, and
   * a fare matched from text instead of measured. `shortcutPlaces` holds the
   * server's own names and positions, so a chip now prices exactly as the
   * same place picked from the suggestions would.
   */
  static const _hubIcon = Icons.flight_takeoff_rounded;

  /// The codes travellers actually recognise, kept beside the chip rather than
  /// inside the place: an IATA code belongs to an airport, not to one end of
  /// somebody's journey.
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
