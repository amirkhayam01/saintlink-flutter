import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import 'customer.dart';

/// Who is signed in, if anyone.
@immutable
class AuthState {
  const AuthState({this.customer, this.isRestoring = true});

  /// The app starts here: a token may exist in secure storage, and until it has
  /// been checked the router must not decide the customer is a guest and throw
  /// them out to the sign-in screen.
  const AuthState.restoring() : this(isRestoring: true);

  const AuthState.guest() : this(isRestoring: false);

  const AuthState.signedIn(Customer customer) : this(customer: customer, isRestoring: false);

  final Customer? customer;
  final bool isRestoring;

  bool get isSignedIn => customer != null;
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(_restore);

    return const AuthState.restoring();
  }

  /// Reinstates a previous session, if the stored token still works.
  Future<void> _restore() async {
    final repository = ref.read(authRepositoryProvider);

    if (!await repository.hasStoredSession()) {
      state = const AuthState.guest();

      return;
    }

    try {
      state = AuthState.signedIn(await repository.me());
    } on ApiException catch (error) {
      /*
       * A rejected token means the session is over — signed out elsewhere, or
       * revoked. Anything else is probably the network, and treating that as a
       * sign-out would log a customer out every time they opened the app in a
       * tunnel, so the stored token is kept and only this session is guest.
       */
      if (error.isUnauthenticated) {
        await repository.signOut();
      }

      state = const AuthState.guest();
    }
  }

  Future<void> completeSignIn(Customer customer) async {
    state = AuthState.signedIn(customer);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthState.guest();
  }

  void applyProfile(Customer customer) {
    state = AuthState.signedIn(customer);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
