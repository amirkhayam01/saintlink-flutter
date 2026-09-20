import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/api_client.dart';
import 'package:saints_link/src/core/api_exception.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/core/theme.dart';
import 'package:saints_link/src/core/token_store.dart';
import 'package:saints_link/src/features/auth/auth_controller.dart';
import 'package:saints_link/src/features/auth/demo_session.dart';
import 'package:saints_link/src/features/profile/profile_controller.dart';
import 'package:saints_link/src/features/trips/trips_controller.dart';
import 'package:saints_link/src/router.dart';

import '../support/fakes.dart';
import '../fixtures/fixtures.dart';

class PreviewApi implements ApiClient {
  final calls = <String>[];
  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    calls.add(path);
    if (path == '/vehicle-categories') return loadFixture('vehicle_categories');
    throw StateError('Unexpected API request: $path');
  }

  @override
  Future<Map<String, dynamic>> post(String path, {Object? body}) async {
    calls.add(path);
    throw StateError('Unexpected API write: $path');
  }

  @override
  Future<Map<String, dynamic>> patch(String path, {Object? body}) async {
    calls.add(path);
    throw StateError('Unexpected API write: $path');
  }

  @override
  Future<Map<String, dynamic>> delete(String path) async {
    calls.add(path);
    throw StateError('Unexpected API write: $path');
  }
}

class PreviewTokens implements TokenStore {
  int writes = 0;
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String token) async => writes++;
  @override
  Future<void> clear() async {}
}

void main() {
  testWidgets(
    'demo login opens protected screens and keeps all account data local',
    (tester) async {
      final api = PreviewApi();
      final tokens = PreviewTokens();
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          tokenStoreProvider.overrideWithValue(tokens),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(routerProvider);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trips'));
      await tester.pumpAndSettle();
      expect(find.text('Demo login'), findsOneWidget);
      await tester.tap(find.text('Demo login'));
      await tester.pumpAndSettle();
      expect(container.read(authControllerProvider).isSignedIn, isTrue);
      expect(find.text('My trips'), findsOneWidget);
      expect(find.text('Demo account · sample trips'), findsOneWidget);
      final trips = await container.read(tripsProvider.future);
      expect(trips.upcoming.length, 2);
      expect(trips.past.length, 1);
      final detail = await container.read(tripDetailProvider('DEMO-3').future);
      expect(detail.legs, isNotEmpty);
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      expect(find.text('Alex Morgan'), findsOneWidget);
      expect(
        await container
            .read(profileControllerProvider.notifier)
            .save(
              firstName: 'Sam',
              lastName: 'Morgan',
              email: 'sam@example.com',
              marketingConsent: true,
            ),
        isTrue,
      );
      await tester.pumpAndSettle();
      expect(find.text('Sam Morgan'), findsOneWidget);
      final repository = container.read(bookingRepositoryProvider);
      await expectLater(
        repository.createBooking(
          journey: quotableJourney,
          quoteToken: 'preview',
          vehicleCategorySlug: 'saloon-car',
          customerName: 'Sam',
          customerPhone: '+447700900123',
        ),
        throwsA(isA<ApiException>()),
      );
      await expectLater(
        repository.paymentIntent('DEMO-3'),
        throwsA(isA<ApiException>()),
      );
      await container.read(authControllerProvider.notifier).signOut();
      router.go('/');
      await tester.pumpAndSettle();
      expect(container.read(demoSessionProvider), isNull);
      expect(container.read(authControllerProvider).isSignedIn, isFalse);
      expect(tokens.writes, 0);
      expect(api.calls.where((path) => path != '/vehicle-categories'), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'starting demo before restoration cannot be replaced by guest restoration',
    () async {
      final container = ProviderContainer.test(
        overrides: [
          apiClientProvider.overrideWithValue(PreviewApi()),
          tokenStoreProvider.overrideWithValue(PreviewTokens()),
        ],
      );
      container.read(authControllerProvider.notifier).signInDemo();
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(authControllerProvider).customer?.name,
        'Alex Morgan',
      );
    },
  );
}
