import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/api_exception.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/features/auth/auth_controller.dart';

import '../../support/fakes.dart';

void main() {
  late FakeAuthRepository auth;
  late ProviderContainer container;

  setUp(() {
    auth = FakeAuthRepository();
    container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
  });

  Future<AuthState> restored() async {
    container.read(authControllerProvider);
    await Future<void>.delayed(Duration.zero);

    return container.read(authControllerProvider);
  }

  test('starts restoring so the router does not bounce anyone', () {
    expect(container.read(authControllerProvider).isRestoring, isTrue);
  });

  test('no stored token means guest', () async {
    final state = await restored();

    expect(state.isRestoring, isFalse);
    expect(state.isSignedIn, isFalse);
  });

  test('a working token restores the customer', () async {
    auth.hasSession = true;

    final state = await restored();

    expect(state.customer, customer);
  });

  test('a rejected token ends the session', () async {
    auth
      ..hasSession = true
      ..meError = const ApiException('Unauthenticated.', statusCode: 401);

    final state = await restored();

    expect(state.isSignedIn, isFalse);
    expect(auth.signOutCalls, 1);
  });

  test('a network failure keeps the token for next time', () async {
    auth
      ..hasSession = true
      ..meError = const ApiException('You appear to be offline.');

    final state = await restored();

    // Guest for this launch, but not signed out: opening the app in a tunnel
    // must not cost the customer their session.
    expect(state.isSignedIn, isFalse);
    expect(auth.signOutCalls, 0);
    expect(auth.hasSession, isTrue);
  });

  test('sign out clears the session even before restore finished', () async {
    auth.hasSession = true;
    await restored();

    await container.read(authControllerProvider.notifier).signOut();

    expect(container.read(authControllerProvider).isSignedIn, isFalse);
    expect(auth.signOutCalls, 1);
  });
}
