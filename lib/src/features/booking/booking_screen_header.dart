import 'package:flutter/material.dart';

import '../../widgets/inner_screen_header.dart';
import 'journey_draft.dart';

/// The midnight header every booking step wears, with the step's title.
class BookingScreenHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const BookingScreenHeader({
    super.key,
    required this.title,
    required this.journey,
    this.onBack,
    this.actions = const [],
    this.curvedEdge = true,
  });

  final String title;
  final JourneyDraft journey;
  final VoidCallback? onBack;
  final List<Widget> actions;

  /// See [InnerScreenHeader.curvedEdge].
  final bool curvedEdge;

  @override
  Size get preferredSize => Size.fromHeight(curvedEdge ? 80 : 60);

  @override
  Widget build(BuildContext context) => InnerScreenHeader(
    title: title,
    onBack: onBack,
    curvedEdge: curvedEdge,
    actions: actions,
  );
}
