import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../widgets/inner_screen_header.dart';

class DriverEarningsScreen extends ConsumerWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: InnerScreenHeader(
        title: 'Earnings',
        showBack: false,
        background: InnerScreenHeader.midnightBackground(),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            Text(
              'Track your shift income, tips, bonuses, and weekly bank payouts.',
              style: TextStyle(
                fontSize: 13,
                color: colors.inkMuted,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),

            // Today's Earnings Card with Bar Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.inkFaint),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Earnings",
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.inkMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              size: 11,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 3),
                            Text(
                              '+12% vs yesterday',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '£86.40',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: colors.ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Weekly 7 Days Bar Chart
                  SizedBox(
                    width: double.infinity,
                    height: 125,
                    child: CustomPaint(
                      painter: _WeeklyBarChartPainter(
                        brandColor: AppTheme.brand,
                        trackColor: colors.inkFaint.withValues(alpha: 0.4),
                        labelColor: colors.inkMuted,
                        activeLabelColor: colors.ink,
                        todayIndex: 3, // Thursday (Today £86.40)
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // This Week vs Last Week
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.inkFaint),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This Week',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.inkMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '£542.30',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: colors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '33 trips completed',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.inkFaint),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Week',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.inkMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '£498.60',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: colors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '28 trips completed',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Detailed Breakdown Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.inkFaint),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earnings Breakdown',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _EarningsRow(
                    icon: Icons.directions_car_outlined,
                    label: 'Trip Fares',
                    value: '£482.00',
                    colors: colors,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: colors.inkFaint, height: 1),
                  ),
                  _EarningsRow(
                    icon: Icons.volunteer_activism_outlined,
                    label: 'Passenger Tips',
                    value: '£32.40',
                    colors: colors,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: colors.inkFaint, height: 1),
                  ),
                  _EarningsRow(
                    icon: Icons.military_tech_outlined,
                    label: 'Airport Bonuses',
                    value: '£28.00',
                    colors: colors,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Payout Details Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.inkFaint),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.brand.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_outlined,
                      color: AppTheme.brandDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Bank Payout: Fri, 26 Sep',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: colors.ink,
                          ),
                        ),
                        Text(
                          'Direct deposit to Barclays •••• 4589',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
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

class _EarningsRow extends StatelessWidget {
  const _EarningsRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final String value;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.inkMuted),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.ink,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colors.ink,
          ),
        ),
      ],
    );
  }
}

class _WeeklyBarChartPainter extends CustomPainter {
  const _WeeklyBarChartPainter({
    required this.brandColor,
    required this.trackColor,
    required this.labelColor,
    required this.activeLabelColor,
    this.todayIndex = 3,
  });

  final Color brandColor;
  final Color trackColor;
  final Color labelColor;
  final Color activeLabelColor;
  final int todayIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final heights = [0.45, 0.65, 0.55, 0.85, 0.70, 0.95, 0.60];
    final barCount = days.length;
    final slotW = size.width / barCount;
    final barW = (slotW * 0.42).clamp(14.0, 26.0);
    const bottomLabelH = 22.0;
    final chartH = size.height - bottomLabelH;

    // Subtle background guidelines
    final gridPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dashY1 = chartH * 0.5;
    canvas.drawLine(Offset(0, dashY1), Offset(size.width, dashY1), gridPaint);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;

    final activeBarPaint = Paint()
      ..color = brandColor
      ..style = PaintingStyle.fill;

    final inactiveBarPaint = Paint()
      ..color = brandColor.withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < barCount; i++) {
      final isToday = i == todayIndex;
      final x = (i * slotW) + (slotW - barW) / 2;
      final cornerRadius = Radius.circular(barW / 2);

      // Background track capsule
      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 6, barW, chartH - 6),
        cornerRadius,
      );
      canvas.drawRRect(trackRect, trackPaint);

      // Filled portion capsule
      final fillH = (heights[i] * (chartH - 12)).clamp(barW, chartH - 6);
      final y = chartH - fillH;
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barW, fillH),
        cornerRadius,
      );
      canvas.drawRRect(fillRect, isToday ? activeBarPaint : inactiveBarPaint);

      // Day label
      textPainter.text = TextSpan(
        text: days[i],
        style: TextStyle(
          fontSize: isToday ? 11.5 : 10.5,
          fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
          color: isToday ? activeLabelColor : labelColor,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (i * slotW) + (slotW - textPainter.width) / 2,
          chartH + 6,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyBarChartPainter oldDelegate) {
    return oldDelegate.brandColor != brandColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.activeLabelColor != activeLabelColor ||
        oldDelegate.todayIndex != todayIndex;
  }
}

