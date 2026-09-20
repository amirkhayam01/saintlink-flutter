import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// A moment of brand at launch. Above the router, so a deep link still lands where it says.
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({
    super.key,
    required this.child,
    this.hold = const Duration(milliseconds: 1400),
  });

  final Widget child;
  final Duration hold;

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> {
  var _visible = true;
  var _mounted = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.hold, () => setState(() => _visible = false));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_mounted)
          IgnorePointer(
            ignoring: !_visible,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              onEnd: () {
                if (!_visible) setState(() => _mounted = false);
              },
              child: const _Splash(),
            ),
          ),
      ],
    );
  }
}

/// Light ground, the logo, a slim gold bar while the app comes up.
class _Splash extends StatefulWidget {
  const _Splash();

  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> with SingleTickerProviderStateMixin {
  late final _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  late final _fade = CurvedAnimation(parent: _enter, curve: Curves.easeOut);
  late final _rise = Tween(
    begin: 0.96,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colors = AppColors.light;

    return Material(
      color: colors.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _rise,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 56),
                    child: Image.asset(
                      'assets/brand/logo-light.png',
                      fit: BoxFit.contain,
                      height: 64,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              FadeTransition(
                opacity: _fade,
                child: const SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      color: AppTheme.brand,
                      backgroundColor: Color(0x33FACC15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 44,
            child: FadeTransition(
              opacity: _fade,
              child: Text(
                'Airport, cruise and private hire transfers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.inkMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
