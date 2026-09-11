import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/api_exception.dart';
import 'package:saints_link/src/core/providers.dart';
import 'package:saints_link/src/features/auth/auth_controller.dart';
import 'package:saints_link/src/features/profile/profile_controller.dart';

import '../../support/fakes.dart';

void main() {
  late FakeAuthRepository auth;
  late ProviderContainer container;

  setUp(() async {
    auth = FakeAuthRepository()..hasSession = true;
    container = ProviderContainer.test(overrides: [authRepositoryProvider.overrideWithValue(auth)]);
    container.read(authControllerProvider);
    await Future<void>.delayed(Duration.zero);
  });

  test('saves trimmed values, blanks as null, and updates the session', () async {
    final saved = await container.read(profileControllerProvider.notifier).save(
          firstName: '  Grace ',
          lastName: '',
          email: ' Grace@Example.com ',
          marketingConsent: true,
        );

    expect(saved, isTrue);
    expect(auth.profileUpdates.single, {
      'first_name': 'Grace',
      'last_name': null,
      'email': 'grace@example.com',
      'marketing_consent': true,
    });
    expect(container.read(authControllerProvider).customer?.name, 'Grace');
    expect(container.read(profileControllerProvider), const ProfileState());
  });

  test('a validation failure keeps the field errors and leaves the session alone', () async {
    auth.updateError = const ApiException('The given data was invalid.', statusCode: 422, fieldErrors: {'email': ['Please enter a valid email address.']});

    final saved = await container.read(profileControllerProvider.notifier).save(
          firstName: 'Ada',
          lastName: 'Lovelace',
          email: 'not-an-email',
          marketingConsent: false,
        );

    expect(saved, isFalse);
    expect(container.read(profileControllerProvider).fieldErrors['email'], isNotEmpty);
    expect(container.read(profileControllerProvider).isSaving, isFalse);
    expect(container.read(authControllerProvider).customer, customer);
  });
}
