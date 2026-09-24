import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../core/theme_controller.dart';
import '../../auth/auth_controller.dart';

class DriverSettingsScreen extends ConsumerWidget {
  const DriverSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.ink,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
        children: [
          Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.inkFaint),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Account Information',
                  onTap: () {},
                  colors: colors,
                ),
                Divider(color: colors.inkFaint, height: 1),
                _SettingsTile(
                  icon: Icons.directions_car_outlined,
                  title: 'Vehicle Information',
                  onTap: () {},
                  colors: colors,
                ),
                Divider(color: colors.inkFaint, height: 1),
                _SettingsTile(
                  icon: Icons.account_balance_outlined,
                  title: 'Bank Details',
                  onTap: () {},
                  colors: colors,
                ),
                Divider(color: colors.inkFaint, height: 1),
                // Notifications Switch
                ListTile(
                  leading: Icon(Icons.notifications_none_rounded, color: colors.ink),
                  title: Text(
                    'Notifications',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.ink),
                  ),
                  trailing: Transform.scale(
                    scale: 0.85,
                    child: Switch.adaptive(
                      value: true,
                      activeTrackColor: AppTheme.brand,
                      onChanged: (_) {},
                    ),
                  ),
                ),
                Divider(color: colors.inkFaint, height: 1),
                // Dark Theme Toggle Switch (Requested by user)
                ListTile(
                  leading: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppTheme.brandDark,
                  ),
                  title: Text(
                    'Dark Theme',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.ink),
                  ),
                  subtitle: Text(
                    isDark ? 'Dark mode is ON' : 'Light mode is ON',
                    style: TextStyle(fontSize: 11.5, color: colors.inkMuted),
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
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  trailingText: 'English',
                  onTap: () {},
                  colors: colors,
                ),
                Divider(color: colors.inkFaint, height: 1),
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () {},
                  colors: colors,
                ),
                Divider(color: colors.inkFaint, height: 1),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy Policy',
                  onTap: () {},
                  colors: colors,
                ),
                Divider(color: colors.inkFaint, height: 1),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () {},
                  colors: colors,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.danger,
              side: const BorderSide(color: AppTheme.danger),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/sign-in');
              }
            },
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailingText,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: colors.ink, size: 20),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.ink),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(trailingText!, style: TextStyle(fontSize: 12.5, color: colors.inkMuted)),
            const SizedBox(width: 4),
          ],
          Icon(Icons.chevron_right_rounded, size: 18, color: colors.inkMuted),
        ],
      ),
      onTap: onTap,
    );
  }
}
