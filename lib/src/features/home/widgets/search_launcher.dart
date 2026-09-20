import 'package:flutter/material.dart';

import '../../../domain/place.dart';
import '../../places/place_autocomplete_field.dart';

/// The "Where can we take you?" bar that opens the booking form.
class SearchLauncher extends StatelessWidget {
  const SearchLauncher({
    super.key,
    required this.onSelectPlace,
    this.gutter = 18,
  });

  final ValueChanged<PlaceSelection> onSelectPlace;
  final double gutter;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: gutter),
    child: PlaceAutocompleteField(onSelected: onSelectPlace),
  );
}
