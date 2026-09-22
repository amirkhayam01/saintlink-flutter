import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../domain/place.dart';
import '../../places/recent_places.dart';
import '../../../widgets/common.dart';
import '../../../widgets/list_row.dart';
import '../../auth/auth_controller.dart';

/// Personal history belongs only to a signed-in returning customer. New and
/// signed-out customers move directly from search to the service choices.
class RecentPlacesSection extends ConsumerWidget {
  const RecentPlacesSection({
    super.key,
    required this.onSelect,
    this.spacingBelow = 0,
  });

  final ValueChanged<PlaceSelection> onSelect;
  final double spacingBelow;

  /// Long enough to be worth scanning, short enough not to push the rest of
  /// the screen below the fold.
  static const _maxRows = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(
      authControllerProvider.select((auth) => auth.isSignedIn),
    );
    final places = ref.watch(goAgainPlacesProvider).take(_maxRows).toList();

    if (!isSignedIn || places.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Recent destinations'),
        const SizedBox(height: 4),
        for (final place in places)
          ListRow(
            icon: Icons.history_rounded,
            iconColor: context.colors.inkMuted,
            title: place.address,
            chevron: true,
            onTap: () => onSelect(place),
          ),
        SizedBox(height: spacingBelow),
      ],
    );
  }
}
