import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../widgets/driver_header.dart';

class DriverEarningsScreen extends ConsumerWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const DriverHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  Text(
                    'Earnings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_upward_rounded, size: 11, color: Color(0xFF10B981)),
                                  SizedBox(width: 3),
                                  Text(
                                    '12% • 6 trips',
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
                        const SizedBox(height: 4),
                        Text(
                          '£86.40',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: colors.ink,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Weekly 7 Days Bar Chart
                        SizedBox(
                          height: 110,
                          child: CustomPaint(
                            painter: _WeeklyBarChartPainter(
                              barColor: AppTheme.brand,
                              labelColor: colors.inkMuted,
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
                                style: TextStyle(fontSize: 11.5, color: colors.inkMuted, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '£542.30',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.ink),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '33 trips',
                                style: TextStyle(fontSize: 11, color: colors.inkMuted),
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
                                style: TextStyle(fontSize: 11.5, color: colors.inkMuted, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '£498.60',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.ink),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '28 trips',
                                style: TextStyle(fontSize: 11, color: colors.inkMuted),
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
                      children: [
                        _EarningsRow(
                          icon: Icons.directions_car_outlined,
                          label: 'Trip Earnings',
                          value: '£482.00',
                          colors: colors,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: colors.inkFaint, height: 1),
                        ),
                        _EarningsRow(
                          icon: Icons.volunteer_activism_outlined,
                          label: 'Tips',
                          value: '£32.40',
                          colors: colors,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(color: colors.inkFaint, height: 1),
                        ),
                        _EarningsRow(
                          icon: Icons.military_tech_outlined,
                          label: 'Bonuses',
                          value: '£28.00',
                          colors: colors,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // View Full Report Button
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.midnight,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {},
                    child: const Text('View Full Report', style: TextStyle(fontWeight: FontWeight.w700)),
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
        Icon(icon, size: 16, color: colors.inkMuted),
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
    required this.barColor,
    required this.labelColor,
  });

  final Color barColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    const bottomPad = 20.0;
    final chartH = size.height - bottomPad;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final heights = [0.4, 0.65, 0.5, 0.75, 0.9, 0.6, 0.85];

    final slotW = size.width / days.length;
    final barW = 12.0;

    final barPaint = Paint()..color = barColor;
    final textStyle = TextStyle(fontSize: 10, color: labelColor, fontWeight: FontWeight.w500);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < days.length; i++) {
      final bH = heights[i] * chartH;
      final x = (i * slotW) + (slotW - barW) / 2;
      final y = chartH - bH;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barW, bH),
        const Radius.circular(4),
      );
      canvas.drawRRect(rrect, barPaint);

      textPainter.text = TextSpan(text: days[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((i * slotW) + (slotW - textPainter.width) / 2, chartH + 5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyBarChartPainter oldDelegate) => false;
}
