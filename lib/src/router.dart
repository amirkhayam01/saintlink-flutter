import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/booking/booking_flow_controller.dart';
import 'features/booking/confirmation_screen.dart';
import 'features/booking/details_screen.dart';
import 'features/booking/journey_screen.dart';
import 'features/booking/vehicle_screen.dart';
import 'features/home/home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/services/prices_screen.dart';
import 'features/services/service_screen.dart';
import 'features/trips/trip_detail_screen.dart';
import 'features/trips/trips_screen.dart';
import 'widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Rebuilds the router's redirect when sign-in state changes, without
/// recreating the router and losing the navigation stack.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);
  ref.onDispose(listenable.dispose);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final needsSignIn =
          state.matchedLocation.startsWith('/trips') ||
          state.matchedLocation.startsWith('/profile');

      // No redirects until the stored session is checked, or every launch flickers past sign-in.
      if (auth.isRestoring) return null;

      if (needsSignIn && !auth.isSignedIn) {
        return Uri(
          path: '/sign-in',
          queryParameters: {'redirect': state.matchedLocation},
        ).toString();
      }

      if (state.matchedLocation == '/sign-in' && auth.isSignedIn) {
        return state.uri.queryParameters['redirect'] ?? '/trips';
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'services/airport',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) =>
                        const ServiceScreen(kind: ServiceKind.airport),
                  ),
                  GoRoute(
                    path: 'services/cruise',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) =>
                        const ServiceScreen(kind: ServiceKind.cruise),
                  ),
                  GoRoute(
                    path: 'prices',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const PricesScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trips',
                builder: (_, _) => const TripsScreen(),
                routes: [
                  GoRoute(
                    path: ':reference',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, state) => TripDetailScreen(
                      reference: state.pathParameters['reference']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // The booking form pushes over the shell rather than living in a tab.
      GoRoute(
        path: '/book',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const JourneyScreen(),
        routes: [
          GoRoute(
            path: 'vehicle',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (_, _) => const VehicleScreen(),
          ),
          GoRoute(
            path: 'details',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (_, _) => const DetailsScreen(),
          ),
          GoRoute(
            path: 'confirmed',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (_, _) => const ConfirmationScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/sign-in',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            SignInScreen(redirectTo: state.uri.queryParameters['redirect']),
      ),
    ],
  );
  var previousPath = router.routeInformationProvider.value.uri.path;
  void resetBookingOnHome() {
    final path = router.routeInformationProvider.value.uri.path;
    if (path == '/' && previousPath != '/') {
      ref.read(bookingFlowProvider.notifier).reset();
    }
    previousPath = path;
  }

  router.routeInformationProvider.addListener(resetBookingOnHome);
  ref.onDispose(() {
    router.routeInformationProvider.removeListener(resetBookingOnHome);
    router.dispose();
  });
  return router;
});
