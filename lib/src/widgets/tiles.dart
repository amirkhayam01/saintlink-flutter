import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The gold-washed circle an icon sits in, used wherever a section or a tile
/// needs a mark: service tiles, trust badges, contact rows.
class IconDisc extends StatelessWidget {
  const IconDisc(this.icon, {super.key, this.size = 48, this.filled = false});

  final IconData icon;
  final double size;

  /// Solid gold with dark glyph, for the one tile that should lead.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? AppTheme.brand : context.colors.tint,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size * 0.5, color: filled ? AppTheme.midnight : AppTheme.brandDark),
    );
  }
}

/// A square tile for the services grid: icon disc, title, one-line caption.
class ServiceTile extends StatelessWidget {
  const ServiceTile({
    super.key,
    required this.icon,
    required this.title,
    this.caption,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.inkFaint),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconDisc(icon, size: 44),
              const SizedBox(height: 14),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.ink, height: 1.2),
              ),
              if (caption != null) ...[
                const SizedBox(height: 3),
                Text(
                  caption!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.inkMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A tappable form row: small uppercase label over the value, leading icon,
/// trailing chevron. Every picker in the journey form is one of these, so the
/// form reads as a list of decisions rather than a stack of text boxes.
class FieldTile extends StatelessWidget {
  const FieldTile({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    required this.placeholder,
    required this.onTap,
    this.trailing,
    this.error,
    this.dense = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final Widget? trailing;
  final String? error;

  /// Half-width tiles (date beside time) drop the chevron to save room.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasValue = value != null && value!.isNotEmpty;
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.fromLTRB(14, 12, dense ? 12 : 10, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: hasError ? AppTheme.danger : colors.inkFaint),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: hasValue ? AppTheme.brandDark : colors.inkMuted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label.toUpperCase(),
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: colors.inkMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasValue ? value! : placeholder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: hasValue ? FontWeight.w600 : FontWeight.w500,
                            color: hasValue ? colors.ink : colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing! else if (!dense) Icon(Icons.chevron_right, color: colors.inkMuted),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 6),
            child: Text(error!, style: const TextStyle(color: AppTheme.danger, fontSize: 12)),
          ),
      ],
    );
  }
}

/// A row that opens something external: call, email, website. Icon disc,
/// title, subtitle, trailing chevron.
class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingIcon = Icons.chevron_right,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.inkFaint),
          ),
          child: Row(
            children: [
              IconDisc(icon, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: colors.ink)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: colors.inkMuted)),
                  ],
                ),
              ),
              Icon(trailingIcon, color: colors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// A pill-shaped two-or-three-way switch, for Upcoming / Past and the price
/// list filters.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({super.key, required this.labels, required this.index, required this.onChanged});

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? colors.card : colors.inkFaint.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: i == index ? (isDark ? AppTheme.brand : AppTheme.midnight) : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: i == index ? (isDark ? AppTheme.midnight : Colors.white) : colors.inkMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A single promise with a big figure: "£125.00 — price agreed before travel".
/// Midnight on the light ground, gold on the dark one, like the primary button.
class CalloutCard extends StatelessWidget {
  const CalloutCard({
    super.key,
    required this.eyebrow,
    required this.headline,
    required this.body,
    this.icon = Icons.verified_outlined,
  });

  final String eyebrow;
  final String headline;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.brand : AppTheme.midnight;
    final fg = isDark ? AppTheme.midnight : Colors.white;
    final fgMuted = fg.withValues(alpha: 0.72);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(color: isDark ? fgMuted : AppTheme.brand, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                ),
                const SizedBox(height: 4),
                Text(headline, style: TextStyle(color: fg, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(color: fgMuted, fontSize: 13, height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: fg.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: isDark ? AppTheme.midnight : AppTheme.brand, size: 26),
          ),
        ],
      ),
    );
  }
}

/// Three side-by-side promises under a hero or a form.
class BadgeRow extends StatelessWidget {
  const BadgeRow({super.key, required this.items});

  final List<({IconData icon, String label, String? caption})> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Expanded(
            child: Column(
              children: [
                IconDisc(item.icon, size: 46),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.ink),
                ),
                if (item.caption != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.caption!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: colors.inkMuted, height: 1.3),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
