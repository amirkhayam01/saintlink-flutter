import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../admin_models.dart';
import '../admin_state.dart';
import '../../../widgets/inner_screen_header.dart';

class AdminAlertsScreen extends ConsumerWidget {
  const AdminAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(adminControllerProvider);
    final selectedFilter = state.selectedAlertFilter;

    final filterCounts = {
      AlertCategory.all: 6,
      AlertCategory.urgent: 2,
      AlertCategory.confirmations: 1,
      AlertCategory.cancellations: 3,
    };

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: InnerScreenHeader(
        title: 'Operations Alerts',
        showBack: false,
        background: InnerScreenHeader.midnightBackground(),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            // Subtitle
            Text(
              'Urgent actions, pending confirmations, and notifications.',
              style: TextStyle(
                fontSize: 13,
                color: colors.inkMuted,
              ),
            ),
            const SizedBox(height: 14),

                  // Filter Pills Row: All (6), Urgent (2), Confirmations (1), Cancellations (3)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterPill(
                          label: 'All (${filterCounts[AlertCategory.all]})',
                          isSelected: selectedFilter == AlertCategory.all,
                          onTap: () {
                            ref
                                .read(adminControllerProvider.notifier)
                                .setAlertFilter(AlertCategory.all);
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterPill(
                          label: 'Urgent (${filterCounts[AlertCategory.urgent]})',
                          isSelected: selectedFilter == AlertCategory.urgent,
                          onTap: () {
                            ref
                                .read(adminControllerProvider.notifier)
                                .setAlertFilter(AlertCategory.urgent);
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterPill(
                          label: 'Confirmations (${filterCounts[AlertCategory.confirmations]})',
                          isSelected: selectedFilter == AlertCategory.confirmations,
                          onTap: () {
                            ref
                                .read(adminControllerProvider.notifier)
                                .setAlertFilter(AlertCategory.confirmations);
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterPill(
                          label: 'Cancellations (${filterCounts[AlertCategory.cancellations]})',
                          isSelected: selectedFilter == AlertCategory.cancellations,
                          onTap: () {
                            ref
                                .read(adminControllerProvider.notifier)
                                .setAlertFilter(AlertCategory.cancellations);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Alert Cards List (exact items from screenshot)
                  _AlertCard(
                    icon: Icons.warning_amber_rounded,
                    iconBgColor: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFEF4444),
                    badgeCount: '23',
                    title: 'Unassigned Journeys',
                    subtitle: 'No driver assigned for 23 journeys. Longest wait: 10 minutes',
                    actionColor: const Color(0xFFEF4444),
                    onAction: () {
                      ref.read(adminControllerProvider.notifier).setNavIndex(1);
                    },
                  ),
                  _AlertCard(
                    icon: Icons.calendar_today_outlined,
                    iconBgColor: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFF59E0B),
                    badgeCount: '21',
                    title: 'Awaiting Confirmation',
                    subtitle: 'Bookings waiting for customer confirmation. Since 10:26 AM',
                    actionColor: const Color(0xFFF59E0B),
                    actionTextColor: AppTheme.midnight,
                    onAction: () {
                      ref.read(adminControllerProvider.notifier).setNavIndex(1);
                    },
                  ),
                  _AlertCard(
                    icon: Icons.highlight_off_rounded,
                    iconBgColor: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFEF4444),
                    badgeCount: '3',
                    title: 'Cancellations',
                    subtitle: '3 bookings were cancelled today. Last cancellation: 8:48 PM',
                    actionColor: const Color(0xFFEF4444),
                    onAction: () {
                      ref.read(adminControllerProvider.notifier).setNavIndex(1);
                    },
                  ),
                  _AlertCard(
                    icon: Icons.info_outline_rounded,
                    iconBgColor: const Color(0xFFDBEAFE),
                    iconColor: const Color(0xFF3B82F6),
                    badgeCount: '1',
                    title: 'New Notification',
                    subtitle: 'Driver has accepted a booking. SL00034 • 2:40 PM',
                    actionColor: const Color(0xFF3B82F6),
                    onAction: () {},
                  ),
                  _AlertCard(
                    icon: Icons.update_rounded,
                    iconBgColor: const Color(0xFFE5E7EB),
                    iconColor: const Color(0xFF6B7280),
                    title: 'System Update',
                    subtitle: 'Core dispatch rules updated successfully',
                    actionColor: const Color(0xFF6B7280),
                    onAction: () {},
                  ),
                ],
              ),
            ),
          );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brand : colors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppTheme.brand : colors.inkFaint,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppTheme.midnight : colors.ink,
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.badgeCount,
    required this.title,
    required this.subtitle,
    required this.actionColor,
    this.actionTextColor = Colors.white,
    required this.onAction,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String? badgeCount;
  final String title;
  final String subtitle;
  final Color actionColor;
  final Color actionTextColor;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.inkFaint),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Box with Badge count
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              if (badgeCount != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1),
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      badgeCount!,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.inkMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Action Button
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: actionTextColor,
              minimumSize: const Size(60, 32),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            onPressed: onAction,
            child: Text(
              'View',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: actionTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
