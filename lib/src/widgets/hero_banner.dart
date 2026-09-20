import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Full-bleed photo with a white title over a midnight gradient.
/// [bottomInset] shortens the layout box, not the paint, so an [OverlapSheet] can ride over the photo.
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
    // Keep the greeting below the toolbar when it wraps or text is enlarged.
    final textWidth = (MediaQuery.sizeOf(context).width - 40).clamp(
      1.0,
      double.infinity,
    );
    double measure(String? text, TextStyle style) {
      if (text == null) return 0;
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: textWidth);
      final result = painter.height;
      painter.dispose();
      return result;
    }

    final contentHeight =
        measure(
          title,
          const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ) +
        measure(subtitle, const TextStyle(fontSize: 14, height: 1.35)) +
        (title != null && subtitle != null ? 6 : 0);
    final minimumHeight = 80 + contentHeight + 24 + bottomInset;
    final fullHeight =
        (height < minimumHeight ? minimumHeight : height) + topPadding;

    return SizedBox(
      height: fullHeight - bottomInset,
      width: double.infinity,
      child: OverflowBox(
        alignment: Alignment.topCenter,
        minHeight: fullHeight,
        maxHeight: fullHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: AppTheme.midnight),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppTheme.heroOverlay),
            ),
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
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 14,
                          height: 1.35,
                        ),
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
                  if (showBack)
                    const HeroIconButton(
                      icon: Icons.arrow_back,
                      semanticLabel: 'Back',
                    ),
                  if (leading != null)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: leading,
                      ),
                    )
                  else
                    const Spacer(),
                  ...actions,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A round, translucent button for sitting over a photo.
class HeroIconButton extends StatelessWidget {
  const HeroIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.semanticLabel,
  });

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

/// A [HeroBanner] and its [OverlapSheet] in one box; as separate slivers the sheet would paint under the photo.
class HeroPage extends StatelessWidget {
  const HeroPage({super.key, required this.hero, required this.sheet});

  final HeroBanner hero;
  final OverlapSheet sheet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [hero, sheet],
    );
  }
}

/// The sheet that rides up over a [HeroBanner]; pair with `bottomInset: OverlapSheet.overlap`.
class OverlapSheet extends StatelessWidget {
  const OverlapSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(18, 24, 18, 8),
  });

  static const double overlap = 22;
  static const double radius = 26;

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(radius)),
      ),
      padding: padding,
      child: child,
    );
  }
}
