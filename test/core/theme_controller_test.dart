import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saints_link/src/core/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to ThemeMode.light', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('toggles between light and dark modes', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.light);

    await container.read(themeModeProvider.notifier).toggleTheme();
    expect(container.read(themeModeProvider), ThemeMode.dark);

    await container.read(themeModeProvider.notifier).toggleTheme();
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('restores saved dark mode from SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({
      'saintslink_theme_mode': 'dark',
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Read to initialize build and schedule microtask
    container.read(themeModeProvider);

    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });
}
