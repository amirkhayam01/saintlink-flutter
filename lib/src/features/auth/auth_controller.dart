import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../domain/customer.dart';
import 'demo_session.dart';

/// Who is signed in, if anyone.
@immutable
class AuthState {
  const AuthState({this.customer, this.isRestoring = true});

  /// Until the stored token is checked the router must not treat the customer as a guest.
  const AuthState.restoring() : this(isRestoring: true);

  const AuthState.guest() : this(isRestoring: false);

  const AuthState.signedIn(Customer customer)
    : this(customer: customer, isRestoring: false);

  final Customer? customer;
  final bool isRestoring;

  bool get isSignedIn => customer != null;
}

class AuthController extends Notifier<AuthState> {
  int _sessionRevision = 0;
  @override
  AuthState build() {
    Future.microtask(_restore);

    return const AuthState.restoring();
  }

  /// Reinstates a previous session, if the stored token still works.
  Future<void> _restore() async {
    if (state.isSignedIn) return;
    final revision = _sessionRevision;
    final repository = ref.read(authRepositoryProvider);
    final stored = await repository.hasStoredSession();
    if (revision != _sessionRevision) return;

    if (!stored) {
      state = const AuthState.guest();

      return;
    }

    try {
      final customer = await repository.me();
      if (revision != _sessionRevision) return;
      state = AuthState.signedIn(customer);
    } on ApiException catch (error) {
      if (revision != _sessionRevision) return;
      // Only a rejected token ends the session; a network failure keeps it for next launch.
      if (error.isUnauthenticated) {
        await repository.signOut();
      }

      if (revision != _sessionRevision) return;
      state = const AuthState.guest();
    }
  }

  void signInDemo() {
    if (!kDebugMode) return;
    _sessionRevision++;
    final customer = ref.read(demoSessionProvider.notifier).start();
    state = AuthState.signedIn(customer);
  }

  Future<void> completeSignIn(Customer customer) async {
    _sessionRevision++;
    state = AuthState.signedIn(customer);
  }

  Future<void> signOut() async {
    _sessionRevision++;
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthState.guest();
  }

  void applyProfile(Customer customer) {
    state = AuthState.signedIn(customer);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
