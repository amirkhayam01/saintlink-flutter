import 'package:flutter/material.dart';

import '../core/theme.dart';

/// One row in a list: an icon, a title, and whatever sits at the end.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.chevron = false,
    this.titleColor,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// A switch, a value, a "Coming soon" — anything the row ends with.
  final Widget? trailing;

  /// A chevron says "this opens something"; leave it off for a row that acts
  /// in place or carries its own control.
  final bool chevron;

  final Color? titleColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Icon(icon, size: 21, color: iconColor ?? colors.ink),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? colors.ink,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: colors.inkMuted),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
            if (chevron) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.inkMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The hairline between rows, indented past the icon column so the icons
/// read as one line down the card.
class ListRowDivider extends StatelessWidget {
  const ListRowDivider({super.key});

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    thickness: 0.8,
    indent: 54,
    color: context.colors.inkFaint.withValues(alpha: 0.7),
  );
}
