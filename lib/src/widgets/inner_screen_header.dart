import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

/// A compact branded toolbar with the rounded content edge used inside the app.
class InnerScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  const InnerScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.showBack = true,
    this.actions = const [],
    this.background,
    this.headerContent,
    this.contentHeight = 0,
    this.titleColor,
  });

  /// Brand gold gradient background for inner screen headers.
  static Widget brandBackground() => const SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.brand, AppTheme.brandDark],
            ),
          ),
        ),
      );

  final String title;
  final VoidCallback? onBack;
  final bool showBack;
  final List<Widget> actions;
  final Widget? background;
  final Widget? headerContent;
  final double contentHeight;
  final Color? titleColor;

  @override
  Size get preferredSize => Size.fromHeight(80 + contentHeight);

  @override
  Widget build(BuildContext context) {
    final effectiveTitleColor = titleColor ??
        (background == null ? Colors.white : AppTheme.midnight);

    return AppBar(
      backgroundColor: background == null
          ? AppTheme.midnight
          : Colors.transparent,
      foregroundColor: effectiveTitleColor,
      /*
       * A transparent bar leaves Flutter guessing at the status bar icons, and
       * it guesses from the transparent colour rather than the background
       * behind it: white icons over gold. The title colour already knows which
       * ground it sits on, so the overlay follows it.
       */
      systemOverlayStyle: effectiveTitleColor == Colors.white
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      flexibleSpace: background == null
          ? null
          : SizedBox.expand(child: background),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 60,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: effectiveTitleColor,
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(20 + contentHeight),
        child: Column(
          children: [
            if (headerContent != null)
              SizedBox(height: contentHeight, child: headerContent),
            Transform.translate(
              offset: const Offset(0, 1),
              child: Container(
                height: 21,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingProgress extends StatelessWidget {
  const BookingProgress({super.key, required this.step});

  final int step;
  static const _labels = ['Journey', 'Vehicle', 'Details'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: i <= step ? colors.accent : colors.inkFaint,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: i == step ? FontWeight.w700 : FontWeight.w500,
                    color: i == step ? colors.ink : colors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
