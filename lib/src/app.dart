import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'core/theme_controller.dart';
import 'features/places/current_location.dart';
import 'features/splash/splash_overlay.dart';
import 'router.dart';

class SaintsLinkApp extends ConsumerStatefulWidget {
  const SaintsLinkApp({super.key});

  @override
  ConsumerState<SaintsLinkApp> createState() => _SaintsLinkAppState();
}

class _SaintsLinkAppState extends ConsumerState<SaintsLinkApp> {
  @override
  void initState() {
    super.initState();
    // Ask for location once the first frame is up, so the pickup can be prefilled.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(currentPlaceProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Saints Link',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: ref.watch(routerProvider),
      builder: (_, child) =>
          SplashOverlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
