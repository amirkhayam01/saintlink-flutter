import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../admin_state.dart';
import '../widgets/admin_header.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const AdminHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  // Greeting & Subtitle
                  Row(
                    children: [
                      Text(
                        'Good morning, Admin! 👋',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: colors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Here's what's happening with your service today.",
                    style: TextStyle(
                      fontSize: 13.5,
                      color: colors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date badge
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.inkFaint),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: colors.inkMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '24 Sept 2026, 12:01',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: colors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2x3 Metric Cards Grid
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.directions_car_outlined,
                          iconColor: const Color(0xFF10B981),
                          title: 'Rides Completed\nToday',
                          value: '0',
                          changeText: 'No change vs yesterday',
                          changeColor: const Color(0xFF10B981),
                          arrowUp: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.currency_pound_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: 'Revenue Today\n',
                          value: '£0',
                          changeText: 'No change vs yesterday',
                          changeColor: const Color(0xFF10B981),
                          arrowUp: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.calendar_today_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'Open Bookings\n',
                          value: '22',
                          changeText: '21 awaiting confirmation',
                          changeColor: const Color(0xFFF59E0B),
                          arrowUp: true,
                          onTap: () {
                            ref.read(adminControllerProvider.notifier).setNavIndex(1);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.warning_amber_rounded,
                          iconColor: const Color(0xFFEF4444),
                          title: 'Unassigned Journeys\n',
                          value: '23',
                          changeText: '23 waiting over 10m',
                          changeColor: const Color(0xFFEF4444),
                          isWarning: true,
                          onTap: () {
                            ref.read(adminControllerProvider.notifier).setNavIndex(3);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.person_outline_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          title: 'Active Drivers\n',
                          value: '3',
                          changeText: '1 offline',
                          changeColor: const Color(0xFFEF4444),
                          arrowUp: false,
                          onTap: () {
                            ref.read(adminControllerProvider.notifier).setNavIndex(2);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.track_changes_rounded,
                          iconColor: const Color(0xFFEF4444),
                          title: 'Cancellation Rate\n',
                          value: '33.3%',
                          changeText: '+66.7% vs prior 7d',
                          changeColor: const Color(0xFFEF4444),
                          arrowUp: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Booking Activity Card
                  InkWell(
                    onTap: () {
                      ref.read(adminControllerProvider.notifier).setNavIndex(4);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Booking Activity',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: colors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Last 7 days by pickup date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: colors.inkMuted,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          // Custom Paint Curve Chart
                          SizedBox(
                            height: 110,
                            child: CustomPaint(
                              painter: _ActivityChartPainter(
                                gridColor: colors.inkFaint,
                                labelColor: colors.inkMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.changeText,
    required this.changeColor,
    this.arrowUp,
    this.isWarning = false,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String changeText;
  final Color changeColor;
  final bool? arrowUp;
  final bool isWarning;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colors.inkMuted,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (isWarning)
                    Icon(Icons.circle, size: 6, color: changeColor)
                  else if (arrowUp != null)
                    Icon(
                      arrowUp! ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      size: 11,
                      color: changeColor,
                    ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      changeText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: changeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityChartPainter extends CustomPainter {
  const _ActivityChartPainter({
    required this.gridColor,
    required this.labelColor,
  });

  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 20.0;
    final w = size.width - leftPadding;
    final h = size.height;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8;

    final textStyle = TextStyle(fontSize: 9.5, color: labelColor);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i <= 4; i++) {
      final y = h - (i / 4.0) * (h - 10);
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);

      textPainter.text = TextSpan(text: '$i', style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    // Blue Line Curve
    final bluePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final bluePath = Path();
    bluePath.moveTo(leftPadding, h * 0.9);
    bluePath.cubicTo(
      leftPadding + w * 0.25,
      h * 0.25,
      leftPadding + w * 0.45,
      h * 0.25,
      leftPadding + w * 0.65,
      h * 0.6,
    );
    bluePath.cubicTo(
      leftPadding + w * 0.8,
      h * 0.85,
      leftPadding + w * 0.9,
      h * 0.9,
      size.width,
      h * 0.9,
    );
    canvas.drawPath(bluePath, bluePaint);

    // Pink / Red Line Curve
    final pinkPaint = Paint()
      ..color = const Color(0xFFEC4899)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pinkPath = Path();
    pinkPath.moveTo(leftPadding, h * 0.95);
    pinkPath.cubicTo(
      leftPadding + w * 0.35,
      h * 0.95,
      leftPadding + w * 0.5,
      h * 0.55,
      leftPadding + w * 0.65,
      h * 0.65,
    );
    pinkPath.cubicTo(
      leftPadding + w * 0.78,
      h * 0.75,
      leftPadding + w * 0.88,
      h * 0.95,
      size.width,
      h * 0.95,
    );
    canvas.drawPath(pinkPath, pinkPaint);
  }

  @override
  bool shouldRepaint(covariant _ActivityChartPainter oldDelegate) => false;
}
