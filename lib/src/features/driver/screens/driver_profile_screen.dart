import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../core/theme_controller.dart';
import '../../../widgets/inner_screen_header.dart';
import '../../../widgets/list_row.dart';
import '../../auth/auth_controller.dart';
import '../driver_state.dart';

class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key, this.showBack = false});

  final bool showBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: InnerScreenHeader(
        title: 'Account',
        showBack: showBack,
        background: InnerScreenHeader.midnightBackground(),
        contentHeight: _DriverIdentity.height,
        headerContent: const _DriverIdentity(),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 36),
          children: [
            // ── Driver & Vehicle ──
            const _SectionTitle('Driver & Vehicle'),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListRow(
                    icon: Icons.person_outline_rounded,
                    title: 'Driver Details',
                    subtitle: 'John Smith · +44 7123 456789',
                    chevron: true,
                    onTap: () {},
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.directions_car_outlined,
                    title: 'Assigned Vehicle',
                    subtitle: 'Toyota Corolla · White (2021) · ABC 123',
                    chevron: true,
                    onTap: () {},
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.verified_user_outlined,
                    title: 'Licence & Insurance',
                    subtitle: 'Private Hire Licence (PCO) · Verified & Active',
                    chevron: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── Earnings & Payouts ──
            const _SectionTitle('Earnings & Payouts'),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListRow(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Payout Settings',
                    subtitle: 'Weekly payout to Barclays •••• 4589',
                    chevron: true,
                    onTap: () {
                      ref
                          .read(driverControllerProvider.notifier)
                          .setNavIndex(2);
                    },
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.receipt_long_outlined,
                    title: 'Tax Invoices & Summaries',
                    subtitle: 'Download monthly and annual statements',
                    chevron: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

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
                    title: 'Trip Notifications',
                    subtitle: 'Loud alert for new booking dispatch',
                    trailing: Transform.scale(
                      scale: 0.85,
                      alignment: Alignment.centerRight,
                      child: Switch.adaptive(
                        value: true,
                        activeTrackColor: AppTheme.brand,
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.navigation_outlined,
                    title: 'Navigation App',
                    subtitle: 'Built-in Saints Link Navigation',
                    chevron: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── Switch App ──
            const _SectionTitle('Switch View'),
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
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Admin Console',
                    chevron: true,
                    onTap: () => context.go('/admin'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── Support & Security ──
            const _SectionTitle('Support & Security'),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListRow(
                    icon: Icons.support_agent_rounded,
                    title: '24/7 Driver Support & Dispatch',
                    chevron: true,
                    onTap: () {},
                  ),
                  const ListRowDivider(),
                  ListRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Driver Terms & Privacy Policy',
                    chevron: true,
                    onTap: () {},
                  ),
                  const ListRowDivider(),
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

/// Driver identity header – mirrors _ProfileIdentity from profile_screen.dart.
class _DriverIdentity extends StatelessWidget {
  const _DriverIdentity();

  static const height = 110.0;

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
              'JS',
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
                Row(
                  children: [
                    const Text(
                      'John Smith',
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.25),
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
                const SizedBox(height: 6),
                const _ContactLine(
                  icon: Icons.badge_outlined,
                  text: 'Driver ID: SL-4587 · ★ 4.8 (128 trips)',
                ),
                const SizedBox(height: 3),
                const _ContactLine(
                  icon: Icons.directions_car_filled_rounded,
                  text: 'Toyota Corolla · ABC 123',
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
    final c = Colors.white.withValues(alpha: 0.75);
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
              fontSize: 12.5,
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
