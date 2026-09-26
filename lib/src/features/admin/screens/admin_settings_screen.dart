import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../core/theme_controller.dart';
import '../../../widgets/inner_screen_header.dart';
import '../../../widgets/list_row.dart';
import '../../auth/auth_controller.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: InnerScreenHeader(
        title: 'Settings',
        showBack: false,
        background: InnerScreenHeader.midnightBackground(),
        contentHeight: _AdminIdentity.height,
        headerContent: const _AdminIdentity(),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 36),
          children: [
            // ── App Preferences ──
            const _SectionTitle('App Preferences'),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListRow(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    title: 'Dark mode',
                    trailing: Transform.scale(
                      scale: 0.85,
                      alignment: Alignment.centerRight,
                      child: Switch.adaptive(
                        value: isDark,
                        activeTrackColor: AppTheme.brand,
                        onChanged: (_) =>
                            ref.read(themeModeProvider.notifier).toggleTheme(),
                      ),
                    ),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    trailing: const _ComingSoon(),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.language_rounded,
                    title: 'Language',
                    trailing: const _ComingSoon(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── Navigation ──
            const _SectionTitle('Navigation'),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListRow(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Switch to Customer App',
                    chevron: true,
                    onTap: () => context.go('/'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── Performance Analytics ──
            const _SectionTitle('Performance Analytics'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _AnalyticsCard(
                    icon: Icons.currency_pound_rounded,
                    title: 'Revenue',
                    value: '£12,480',
                    changeText: '+18.4% vs previous period',
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AnalyticsCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Total Bookings',
                    value: '342',
                    changeText: '+12.7% vs previous period',
                    isPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AnalyticsCard(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Completed',
                    value: '318',
                    changeText: '93.0% completion rate',
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AnalyticsCard(
                    icon: Icons.cancel_outlined,
                    title: 'Cancelled',
                    value: '24',
                    changeText: '7.0% cancellation rate',
                    isPositive: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Revenue Trend Bar Chart Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.inkFaint),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Revenue Trend',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                      Text(
                        'View details',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Bar Chart
                  SizedBox(
                    height: 130,
                    child: CustomPaint(
                      painter: _BarChartPainter(
                        barColor: AppTheme.brand,
                        gridColor: colors.inkFaint,
                        labelColor: colors.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── More ──
            const _SectionTitle('More'),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListRow(
                    icon: Icons.logout_rounded,
                    iconColor: AppTheme.danger,
                    title: 'Sign out',
                    titleColor: AppTheme.danger,
                    onTap: () async {
                      await ref
                          .read(authControllerProvider.notifier)
                          .signOut();
                      if (context.mounted) context.go('/sign-in');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Admin identity header – mirrors _ProfileIdentity from profile_screen.dart.
class _AdminIdentity extends StatelessWidget {
  const _AdminIdentity();

  static const height = 100.0;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.brand,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 3,
              ),
            ),
            child: const Text(
              'A',
              style: TextStyle(
                color: AppTheme.midnight,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Admin Console',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                _ContactLine(
                  icon: Icons.phone_outlined,
                  text: '+44 1234568',
                ),
                const SizedBox(height: 3),
                _ContactLine(
                  icon: Icons.mail_outline,
                  text: 'admin@saintslink.co.uk',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = Colors.white.withValues(alpha: 0.72);
    return Row(
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: context.colors.inkMuted,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) => Text(
    'Coming soon',
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: context.colors.inkMuted,
    ),
  );
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.changeText,
    required this.isPositive,
  });

  final IconData icon;
  final String title;
  final String value;
  final String changeText;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color =
        isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.inkFaint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colors.inkMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: colors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: colors.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (isPositive)
                Icon(Icons.arrow_upward_rounded, size: 11, color: color),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  changeText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({
    required this.barColor,
    required this.gridColor,
    required this.labelColor,
  });

  final Color barColor;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 32.0;
    const bottomPad = 22.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8;

    final textStyle = TextStyle(fontSize: 9.5, color: labelColor);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final yLabels = ['£2.0k', '£1.0k', '£0'];
    for (var i = 0; i < yLabels.length; i++) {
      final y = (i / (yLabels.length - 1)) * chartH;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width, y),
        gridPaint,
      );

      textPainter.text = TextSpan(text: yLabels[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(0, y - textPainter.height / 2),
      );
    }

    // 14 Bars
    final barValues = [
      0.35, 0.45, 0.60, 0.50, 0.70, 0.85, 0.65,
      0.55, 0.75, 0.68, 0.90, 0.82, 0.95, 0.88,
    ];
    final barCount = barValues.length;
    final slotW = chartW / barCount;
    final barW = (slotW * 0.55).clamp(6.0, 16.0);

    final barPaint = Paint()..color = barColor;

    for (var i = 0; i < barCount; i++) {
      final val = barValues[i];
      final bH = val * chartH;
      final x = leftPad + (i * slotW) + (slotW - barW) / 2;
      final y = chartH - bH;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barW, bH),
        const Radius.circular(3),
      );
      canvas.drawRRect(rrect, barPaint);
    }

    // X Axis Labels
    final xLabels = ['18 Sep', '20 Sep', '22 Sep', '24 Sep'];
    for (var i = 0; i < xLabels.length; i++) {
      final x = leftPad + (i / (xLabels.length - 1)) * (chartW - 30);
      textPainter.text = TextSpan(text: xLabels[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => false;
}
