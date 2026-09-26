import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../widgets/inner_screen_header.dart';
import '../driver_state.dart';

class DriverTripNavigationScreen extends ConsumerStatefulWidget {
  const DriverTripNavigationScreen({super.key});

  @override
  ConsumerState<DriverTripNavigationScreen> createState() =>
      _DriverTripNavigationScreenState();
}

class _DriverTripNavigationScreenState
    extends ConsumerState<DriverTripNavigationScreen> {
  int _step = 0; // 0: Heading to pickup, 1: Arrived, 2: On trip, 3: Completed

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(driverControllerProvider);
    final job = state.activeJob;

    final actionButtonText = switch (_step) {
      0 => '📍 Arrived at Pickup',
      1 => '▶ Start Trip',
      _ => '✓ Complete Trip',
    };

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: InnerScreenHeader(
        title: _step >= 2 ? 'Active Trip' : 'Trip Navigation',
        showBack: true,
        background: InnerScreenHeader.midnightBackground(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: Color(0xFF10B981)),
                    SizedBox(width: 5),
                    Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
        children: [
          // Map Representation Card
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.inkFaint),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _MapRoutePainter(
                      routeColor: AppTheme.brandDark,
                      lineColor: colors.inkFaint,
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.card,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.navigation_rounded,
                        color: AppTheme.brandDark,
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.card.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.inkFaint),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF10B981)),
                              const SizedBox(width: 6),
                              Text(
                                'ETA: 18 min',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colors.ink,
                                ),
                              ),
                            ],
                          ),
                          Container(width: 1, height: 16, color: colors.inkFaint),
                          Row(
                            children: [
                              const Icon(Icons.straighten_rounded, size: 16, color: Color(0xFF3B82F6)),
                              const SizedBox(width: 6),
                              Text(
                                'Distance: 8.4 km',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colors.ink,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Passenger Card with Contact Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.inkFaint),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.brand,
                      child: Text(
                        job.passengerName.isNotEmpty ? job.passengerName[0] : 'S',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.midnight),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.passengerName,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${job.passengersCount} Passengers • ${job.luggageCount} Bags',
                            style: TextStyle(fontSize: 12, color: colors.inkMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.phone_outlined, size: 16),
                        label: const Text('Call Passenger'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.ink,
                          side: BorderSide(color: colors.inkFaint),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                        label: const Text('Message'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.ink,
                          side: BorderSide(color: colors.inkFaint),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Trip Details Card (Pickup, Drop-off, Flight)
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
                Text('Trip Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.ink)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 10, color: Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pickup', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                          Text(job.pickupAddress, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: colors.ink)),
                          Text('4:30 PM', style: TextStyle(fontSize: 12, color: colors.inkMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.5, top: 4, bottom: 4),
                  child: Container(width: 1.5, height: 18, color: colors.inkFaint),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 12, color: AppTheme.brandDark),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Drop-off', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                          Text(job.destinationAddress, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: colors.ink)),
                          Text('5:00 PM (est.)', style: TextStyle(fontSize: 12, color: colors.inkMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (job.flightNumber != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: colors.inkFaint, height: 1),
                  ),
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff_rounded, size: 16, color: colors.inkMuted),
                      const SizedBox(width: 8),
                      Text('Flight: ${job.flightNumber}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: colors.ink)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Fare & Booking Ref summary row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.inkFaint),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fare', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                    const SizedBox(height: 2),
                    Text('£${job.fare.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.ink)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Booking Reference', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                    const SizedBox(height: 2),
                    Text(job.reference, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
                  ],
                ),
              ],
            ),
          ),
        ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        decoration: BoxDecoration(
          color: colors.card,
          border: Border(top: BorderSide(color: colors.inkFaint)),
        ),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.brand,
            foregroundColor: AppTheme.midnight,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () {
            if (_step < 2) {
              setState(() => _step++);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trip completed successfully! Earnings added.')),
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(
            actionButtonText,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _MapRoutePainter extends CustomPainter {
  const _MapRoutePainter({
    required this.routeColor,
    required this.lineColor,
  });

  final Color routeColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF3F4F6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Grid road lines
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), roadPaint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), roadPaint);

    // Dynamic Navigation Route
    final routePaint = Paint()
      ..color = routeColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.85);
    path.lineTo(size.width * 0.35, size.height * 0.65);
    path.lineTo(size.width * 0.55, size.height * 0.4);
    path.lineTo(size.width * 0.85, size.height * 0.2);
    canvas.drawPath(path, routePaint);

    // Car position indicator
    final carPaint = Paint()..color = AppTheme.midnight;
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.4), 6, carPaint);
  }

  @override
  bool shouldRepaint(covariant _MapRoutePainter oldDelegate) => false;
}
