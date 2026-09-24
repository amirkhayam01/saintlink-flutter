import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_state.dart';
import 'screens/admin_alerts_screen.dart';
import 'screens/admin_bookings_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_fleet_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminControllerProvider);
    final currentIndex = state.currentNavIndex;

    final screens = const [
      AdminDashboardScreen(),
      AdminBookingsScreen(),
      AdminFleetScreen(),
      AdminAlertsScreen(),
      AdminSettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(adminControllerProvider.notifier).setNavIndex(index);
        },
      ),
    );
  }
}
