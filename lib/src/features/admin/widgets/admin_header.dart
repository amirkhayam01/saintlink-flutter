import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../core/theme_controller.dart';
import '../../auth/auth_controller.dart';
import '../admin_state.dart';

class AdminHeader extends ConsumerWidget {
  const AdminHeader({super.key, this.notificationCount = 1});

  final int notificationCount;

  void _openAdminMenu(BuildContext context, WidgetRef ref) {
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
                        'A',
                        style: TextStyle(
                          fontSize: 20,
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
                          'Admin Console',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.ink,
                          ),
                        ),
                        Text(
                          'admin@saintslink.co.uk',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                  leading: Icon(Icons.swap_horiz_rounded, color: colors.ink),
                  title: Text(
                    'Switch to Customer View',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
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
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo on Left
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                isDark ? 'assets/brand/logo-dark.png' : 'assets/brand/logo-light.png',
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.brand,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'SL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.midnight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SAINTS LINK',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: colors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Actions on Right: Bell with Badge + Avatar "A"
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: colors.ink,
                      size: 24,
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: const BoxDecoration(
                            color: AppTheme.danger,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$notificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  ref.read(adminControllerProvider.notifier).setNavIndex(3); // Go to alerts
                },
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _openAdminMenu(context, ref),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: AppTheme.brand,
                  child: const Text(
                    'A',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.midnight,
                    ),
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
