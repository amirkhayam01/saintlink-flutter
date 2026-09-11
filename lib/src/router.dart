import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/booking/confirmation_screen.dart';
import 'features/booking/details_screen.dart';
import 'features/booking/journey_screen.dart';
import 'features/booking/vehicle_screen.dart';
import 'features/trips/trip_detail_screen.dart';
import 'features/trips/trips_screen.dart';

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

  return GoRouter(
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final wantsTrips = state.matchedLocation.startsWith('/trips');

      // Until the stored session has been checked, nobody is sent anywhere:
      // bouncing a signed-in customer to the sign-in screen for half a second
      // on every launch is exactly the flicker this avoids.
      if (auth.isRestoring) return null;

      if (wantsTrips && !auth.isSignedIn) {
        return Uri(path: '/sign-in', queryParameters: {'redirect': state.matchedLocation}).toString();
      }

      if (state.matchedLocation == '/sign-in' && auth.isSignedIn) {
        return state.uri.queryParameters['redirect'] ?? '/trips';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const JourneyScreen(),
        routes: [
          GoRoute(path: 'book/vehicle', builder: (_, _) => const VehicleScreen()),
          GoRoute(path: 'book/details', builder: (_, _) => const DetailsScreen()),
          GoRoute(path: 'book/confirmed', builder: (_, _) => const ConfirmationScreen()),
        ],
      ),
      GoRoute(
        path: '/sign-in',
        builder: (_, state) => SignInScreen(redirectTo: state.uri.queryParameters['redirect']),
      ),
      GoRoute(
        path: '/trips',
        builder: (_, _) => const TripsScreen(),
        routes: [
          GoRoute(path: ':reference', builder: (_, state) => TripDetailScreen(reference: state.pathParameters['reference']!)),
        ],
      ),
    ],
  );
});
