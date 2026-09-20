import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../auth/auth_controller.dart';

part 'profile_controller.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(false) bool isSaving,
    String? error,
    @Default({}) Map<String, List<String>> fieldErrors,
  }) = _ProfileState;
}

/// Editing the customer's details. The phone number is their identity and is not editable here.
class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  /// Saves and, on success, updates the session so every screen that shows the
  /// customer's name or email reflects the change immediately.
  Future<bool> save({
    required String firstName,
    required String lastName,
    required String email,
    required bool marketingConsent,
  }) async {
    state = const ProfileState(isSaving: true);

    try {
      final customer = await ref
          .read(authRepositoryProvider)
          .updateProfile(
            firstName: firstName.trim(),
            lastName: lastName.trim().isEmpty ? null : lastName.trim(),
            email: email.trim().isEmpty ? null : email.trim().toLowerCase(),
            marketingConsent: marketingConsent,
          );
      ref.read(authControllerProvider.notifier).applyProfile(customer);
      state = const ProfileState();

      return true;
    } on ApiException catch (error) {
      state = ProfileState(
        error: error.message,
        fieldErrors: error.fieldErrors,
      );

      return false;
    }
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
