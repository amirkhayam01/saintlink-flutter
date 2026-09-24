import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'driver_state.dart';
import 'screens/driver_bookings_screen.dart';
import 'screens/driver_earnings_screen.dart';
import 'screens/driver_home_screen.dart';
import 'screens/driver_profile_screen.dart';
import 'widgets/driver_bottom_nav.dart';

class DriverShell extends ConsumerWidget {
  const DriverShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverControllerProvider);
    final currentIndex = state.currentNavIndex;

    final screens = const [
      DriverHomeScreen(),
      DriverBookingsScreen(),
      DriverEarningsScreen(),
      DriverProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: DriverBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(driverControllerProvider.notifier).setNavIndex(index);
        },
      ),
    );
  }
}
