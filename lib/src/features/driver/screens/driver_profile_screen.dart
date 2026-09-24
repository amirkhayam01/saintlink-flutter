import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../widgets/driver_header.dart';

class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Driver Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: colors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings_outlined, color: colors.ink, size: 22),
                        onPressed: () {
                          context.push('/driver/settings');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Driver Identity Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.inkFaint),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.brand,
                          child: const Text(
                            'JS',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.midnight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'John Smith',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: colors.ink,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Active',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Driver ID: SL-4587',
                                style: TextStyle(fontSize: 12, color: colors.inkMuted),
                              ),
                              const SizedBox(height: 2),
                              const Row(
                                children: [
                                  Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                  SizedBox(width: 3),
                                  Text(
                                    '4.8 (128 trips)',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Vehicle Details
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
                        Text('Vehicle Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.ink)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.directions_car_filled_rounded, color: colors.ink, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Toyota Corolla', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.ink)),
                                  Text('ABC 123 • White • 2021', style: TextStyle(fontSize: 12, color: colors.inkMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Earnings Overview
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Earnings Overview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.ink)),
                            Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF3B82F6))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Today', style: TextStyle(fontSize: 11.5, color: colors.inkMuted)),
                                  const SizedBox(height: 2),
                                  Text('£86.40', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: colors.ink)),
                                  Text('6 trips', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 36, color: colors.inkFaint),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('This Week', style: TextStyle(fontSize: 11.5, color: colors.inkMuted)),
                                    const SizedBox(height: 2),
                                    Text('£542.30', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: colors.ink)),
                                    Text('33 trips', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Payout Settings
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
                          child: Icon(Icons.account_balance_wallet_outlined, color: AppTheme.brandDark, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Payout Settings', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: colors.ink)),
                              Text('Weekly payout • Next: Fri, 26 Sep', style: TextStyle(fontSize: 11.5, color: colors.inkMuted)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, size: 20, color: colors.inkMuted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Recent History
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
                        Text('Recent History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.ink)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Payout Completed', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink)),
                                  Text('12 Sep 2025', style: TextStyle(fontSize: 11, color: colors.inkMuted)),
                                ],
                              ),
                            ),
                            Text('£320.00', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colors.ink)),
                          ],
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
