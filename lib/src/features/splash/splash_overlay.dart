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

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.midnight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/brand/hero-harbor.webp',
            fit: BoxFit.cover,
            alignment: const Alignment(0.2, 0),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC020617),
                  Color(0x66020617),
                  Color(0xF2020617),
                ],
                stops: [0, 0.5, 1],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/brand/logo-dark.png', height: 56),
              const SizedBox(height: 18),
              const Text(
                'Airport, cruise and private hire transfers',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Text(
              'Southampton · Hampshire · every UK airport and port',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
