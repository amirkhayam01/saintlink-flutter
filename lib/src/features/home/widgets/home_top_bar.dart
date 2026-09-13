import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../auth/auth_controller.dart';

/// The account affordance in the hero's top-right corner: the customer's
/// initial and first name when signed in, a gold "Sign in" pill otherwise.
/// Translucent so it sits on the photo like [HeroIconButton] does.
class HomeAccountChip extends StatelessWidget {
  const HomeAccountChip({super.key, required this.auth, required this.onProfile, required this.onSignIn});

  final AuthState auth;
  final VoidCallback onProfile;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final firstName = auth.customer?.firstName;

    if (!auth.isSignedIn) {
      return Material(
        color: AppTheme.brand,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSignIn,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text('Sign in', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.midnight)),
          ),
        ),
      );
    }

    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onProfile,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.brand,
                child: Text(
                  (firstName != null && firstName.isNotEmpty) ? firstName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.midnight),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                firstName ?? 'Profile',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
