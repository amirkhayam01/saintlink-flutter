import 'package:flutter/material.dart';

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
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBack;
  final List<Widget> actions;
  final Widget? background;
  final Widget? headerContent;
  final double contentHeight;

  @override
  Size get preferredSize => Size.fromHeight(76 + contentHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: background == null
          ? AppTheme.midnight
          : context.colors.surface,
      foregroundColor: background == null ? Colors.white : AppTheme.midnight,
      flexibleSpace: background,
      surfaceTintColor: Colors.transparent,
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
          color: background == null ? Colors.white : AppTheme.midnight,
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(16 + contentHeight),
        child: Column(
          children: [
            if (headerContent != null)
              SizedBox(height: contentHeight, child: headerContent),
            Container(
              height: 16,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
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
