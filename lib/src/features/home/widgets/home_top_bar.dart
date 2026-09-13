import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../auth/auth_controller.dart';

/// Top bar with side drawer trigger, authentic brand logo, theme switcher,
/// and profile/sign-in action.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key, 
    required this.auth,
    required this.onToggleTheme,
    required this.onProfile,
    required this.onSignIn,
  });

  final AuthState auth;
  final VoidCallback onToggleTheme;
  final VoidCallback onProfile;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstName = auth.customer?.firstName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          // Drawer menu icon button
          Builder(
            builder: (ctx) => Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.inkFaint),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                iconSize: 22,
                padding: EdgeInsets.zero,
                tooltip: 'Open menu',
                icon: Icon(Icons.menu_rounded, color: colors.ink),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ),
          const Spacer(),
          // Light/Dark mode switcher button
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: colors.card,
              shape: BoxShape.circle,
              border: Border.all(color: colors.inkFaint),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              iconSize: 20,
              padding: EdgeInsets.zero,
              tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? AppTheme.brand : colors.ink,
              ),
              onPressed: onToggleTheme,
            ),
          ),
          // Profile avatar or sign-in chip
          if (auth.isSignedIn)
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colors.inkFaint),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppTheme.brand,
                      child: Text(
                        (firstName != null && firstName.isNotEmpty) ? firstName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.midnight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      firstName ?? 'Profile',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onSignIn,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.brand : AppTheme.midnight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: isDark ? AppTheme.midnight : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.midnight : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Side navigation drawer housing brand logo, user account details,
/// quick navigation links, and theme toggle switch.
