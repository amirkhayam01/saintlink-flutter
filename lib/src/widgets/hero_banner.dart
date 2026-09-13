import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Full-bleed photography with the title set in white over a midnight
/// gradient. Heads the home, service and contact screens so every landing
/// page opens the same way.
///
/// [bottomInset] leaves room for an [OverlapSheet] to sit over the lower edge;
/// the title moves up by the same amount so it is never hidden.
class HeroBanner extends StatelessWidget {
  const HeroBanner({
    super.key,
    required this.image,
    this.title,
    this.subtitle,
    this.height = 260,
    this.bottomInset = 0,
    this.showBack = false,
    this.leading,
    this.actions = const [],
  });

  final ImageProvider image;
  final String? title;
  final String? subtitle;
  final double height;
  final double bottomInset;
  final bool showBack;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: height + topPadding,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: image,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(color: AppTheme.midnight),
          ),
          const DecoratedBox(decoration: BoxDecoration(gradient: AppTheme.heroOverlay)),
          if (title != null || subtitle != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 24 + bottomInset,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 14, height: 1.35),
                    ),
                  ],
                ],
              ),
            ),
          Positioned(
            top: topPadding + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                if (showBack) const HeroIconButton(icon: Icons.arrow_back, semanticLabel: 'Back'),
                ?leading,
                const Spacer(),
                ...actions,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A round, translucent button for sitting over a photo.
class HeroIconButton extends StatelessWidget {
  const HeroIconButton({super.key, required this.icon, this.onPressed, this.semanticLabel});

  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
        icon: Icon(icon, color: Colors.white, semanticLabel: semanticLabel),
      ),
    );
  }
}

/// The card-coloured sheet that rides up over the bottom of a [HeroBanner].
/// Pair with `HeroBanner(bottomInset: OverlapSheet.overlap)`.
class OverlapSheet extends StatelessWidget {
  const OverlapSheet({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(18, 22, 18, 8)});

  static const double overlap = 22;
  static const double radius = 26;

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -overlap),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(radius)),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
