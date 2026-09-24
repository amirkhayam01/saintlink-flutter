import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/admin/admin_shell.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/booking/confirmation_screen.dart';
import 'features/booking/journey_screen.dart';
import 'features/home/home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/services/prices_screen.dart';
import 'features/services/service_screen.dart';
import 'features/trips/trip_detail_screen.dart';
import 'features/trips/trips_screen.dart';
import 'widgets/app_shell.dart';
import 'widgets/zoom_tab_container.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// go_router 18 only recognises `material_ui`'s MaterialApp, so left to its
/// own devices it wraps our routes in NoTransitionPage. An explicit
/// MaterialPage keeps the theme's zoom transition on every push.
MaterialPage<void> _page(GoRouterState state, Widget child) =>
    MaterialPage(key: state.pageKey, child: child);

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
        if (auth.customer?.name.toLowerCase() == 'admin' ||
            auth.customer?.firstName.toLowerCase() == 'admin') {
          return '/admin';
        }
        return state.uri.queryParameters['redirect'] ?? '/trips';
      }

      return null;
    },
    routes: [
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        // Like indexedStack, every tab keeps its state; unlike it, a switch
        // zooms between tabs instead of cutting.
        navigatorContainerBuilder: (context, navigationShell, children) {
          return ZoomTabContainer(
            index: navigationShell.currentIndex,
            children: children,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (_, state) => _page(state, const HomeScreen()),
                routes: [
                  GoRoute(
                    path: 'services/airport',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (_, state) => _page(
                      state,
                      const ServiceScreen(kind: ServiceKind.airport),
                    ),
                  ),
                  GoRoute(
                    path: 'services/cruise',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (_, state) => _page(
                      state,
                      const ServiceScreen(kind: ServiceKind.cruise),
                    ),
                  ),
                  GoRoute(
                    path: 'prices',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (_, state) =>
                        _page(state, const PricesScreen()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trips',
                pageBuilder: (_, state) => _page(state, const TripsScreen()),
                routes: [
                  GoRoute(
                    path: ':reference',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (_, state) => _page(
                      state,
                      TripDetailScreen(
                        reference: state.pathParameters['reference']!,
                      ),
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
                pageBuilder: (_, state) => _page(state, const ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
      // The booking form pushes over the shell rather than living in a tab.
      GoRoute(
        path: '/book',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (_, state) => _page(state, const JourneyScreen()),
        routes: [
          GoRoute(
            path: 'confirmed',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (_, state) => _page(state, const ConfirmationScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/sign-in',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (_, state) => _page(
          state,
          SignInScreen(redirectTo: state.uri.queryParameters['redirect']),
        ),
      ),
      GoRoute(
        path: '/admin',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (_, state) => _page(state, const AdminShell()),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
