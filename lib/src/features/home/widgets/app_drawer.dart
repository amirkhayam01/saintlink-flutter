import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../core/theme_controller.dart';
import '../../auth/auth_controller.dart';

/// Side navigation drawer housing brand logo, user account details,
/// quick navigation links, and theme toggle switch.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = ref.watch(authControllerProvider);
    final name = auth.customer?.name ?? 'Guest User';
    final email = auth.customer?.email ?? 'Sign in for fast booking';

    return Drawer(
      backgroundColor: colors.card,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    isDark ? 'assets/brand/logo-dark.png' : 'assets/brand/logo-light.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppTheme.brand,
                        child: Text(
                          auth.customer?.firstName.isNotEmpty == true
                              ? auth.customer!.firstName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.midnight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              email,
                              style: TextStyle(fontSize: 13, color: colors.inkMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: colors.inkFaint),
            ListTile(
              leading: Icon(Icons.home_outlined, color: colors.ink),
              title: Text('Home', style: TextStyle(color: colors.ink, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/');
              },
            ),
            ListTile(
              leading: Icon(Icons.commute_outlined, color: colors.ink),
              title: Text('Book a Transfer', style: TextStyle(color: colors.ink, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/book');
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt_long_outlined, color: colors.ink),
              title: Text('My Trips', style: TextStyle(color: colors.ink, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/trips');
              },
            ),
            ListTile(
              leading: Icon(Icons.person_outline_rounded, color: colors.ink),
              title: Text('Profile & Settings', style: TextStyle(color: colors.ink, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/profile');
              },
            ),
            const Spacer(),
            Divider(color: colors.inkFaint),
            // Theme toggle inside the drawer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.inkFaint),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: isDark ? AppTheme.brand : colors.ink,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isDark ? 'Dark Mode' : 'Light Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: colors.ink,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: isDark,
                      activeTrackColor: AppTheme.brand,
                      activeThumbColor: AppTheme.midnight,
                      onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                'Saints Link v0.1.0 · Southampton, UK',
                style: TextStyle(fontSize: 11, color: colors.inkMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dynamic Upcoming Booking snapshot if user has an active ride,
/// or Southampton Concierge welcome banner.
