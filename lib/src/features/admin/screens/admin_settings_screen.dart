import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../core/theme_controller.dart';
import '../../auth/auth_controller.dart';
import '../widgets/admin_header.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AdminHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                children: [
                  // Title & Subtitle
                  Text(
                    'Settings & Analytics',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Track performance metrics, customize theme, and manage settings.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Settings & Preferences First ──
                  Text(
                    'App Preferences',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.inkFaint),
                    ),
                    child: Column(
                      children: [
                        // Dark Theme Toggle Switch Tile
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.brand.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              color: AppTheme.brandDark,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Dark Theme',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: colors.ink,
                            ),
                          ),
                          subtitle: Text(
                            isDark ? 'Dark mode is currently ON' : 'Light mode is currently ON',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.inkMuted,
                            ),
                          ),
                          trailing: Transform.scale(
                            scale: 0.85,
                            child: Switch.adaptive(
                              value: isDark,
                              activeTrackColor: AppTheme.brand,
                              onChanged: (_) {
                                ref.read(themeModeProvider.notifier).toggleTheme();
                              },
                            ),
                          ),
                        ),
                        Divider(color: colors.inkFaint, height: 1),
                        // Account details
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Color(0xFF3B82F6),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Admin Account',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: colors.ink,
                            ),
                          ),
                          subtitle: Text(
                            'admin • +44 1234568',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.inkMuted,
                            ),
                          ),
                        ),
                        Divider(color: colors.inkFaint, height: 1),
                        // Switch to Customer View
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Switch to Customer App',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: colors.ink,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: colors.inkMuted,
                          ),
                          onTap: () {
                            context.go('/');
                          },
                        ),
                        Divider(color: colors.inkFaint, height: 1),
                        // Sign out
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFEF4444),
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                          onTap: () async {
                            await ref.read(authControllerProvider.notifier).signOut();
                            if (context.mounted) {
                              context.go('/sign-in');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Performance & Analytics ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Performance Analytics',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.ink,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.inkFaint),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 12, color: colors.inkMuted),
                            const SizedBox(width: 5),
                            Text(
                              'Last 30 Days',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: colors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2x2 Metric Cards Grid
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    final color = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

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
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colors.inkMuted,
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
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);

      textPainter.text = TextSpan(text: yLabels[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    // 14 Bars
    final barValues = [0.35, 0.45, 0.60, 0.50, 0.70, 0.85, 0.65, 0.55, 0.75, 0.68, 0.90, 0.82, 0.95, 0.88];
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
