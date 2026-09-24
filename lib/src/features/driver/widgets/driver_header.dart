import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../core/theme_controller.dart';
import '../../auth/auth_controller.dart';

class DriverHeader extends ConsumerWidget {
  const DriverHeader({super.key});

  void _openDriverDrawer(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: colors.card,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.inkFaint,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.brand,
                      child: const Text(
                        'JS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.midnight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Smith',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: colors.ink,
                          ),
                        ),
                        Text(
                          'Driver ID: SL-4587 • Toyota Corolla',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    color: colors.ink,
                  ),
                  title: Text(
                    isDark ? 'Light Theme' : 'Dark Theme',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                  ),
                  trailing: Switch.adaptive(
                    value: isDark,
                    activeTrackColor: AppTheme.brand,
                    onChanged: (_) {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.settings_outlined, color: colors.ink),
                  title: Text(
                    'Driver Settings',
                    style: TextStyle(fontWeight: FontWeight.w600, color: colors.ink),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/driver/settings');
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.swap_horiz_rounded, color: colors.ink),
                  title: Text(
                    'Switch to Customer App',
                    style: TextStyle(fontWeight: FontWeight.w600, color: colors.ink),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.go('/');
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout_rounded, color: AppTheme.danger),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.danger,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/sign-in');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.menu_rounded, color: colors.ink, size: 24),
            onPressed: () => _openDriverDrawer(context, ref),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                isDark ? 'assets/brand/logo-dark.png' : 'assets/brand/logo-light.png',
                height: 26,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.brand,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'SL',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.midnight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Saints Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.brand.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Driver',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.brand : AppTheme.brandDark,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: colors.ink, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
