import 'dart:async';
import 'dart:math' as math;

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
    // Count the hold from the first frame the person can see, not from the
    // first build: on a cold start the engine (and the map warm-up on the
    // first frame) can keep the launch screen up for well over a second,
    // and a timer started at build would run out behind it.
    WidgetsBinding.instance.waitUntilFirstFrameRasterized.then((_) {
      if (!mounted) return;
      _timer = Timer(widget.hold, () {
        if (mounted) setState(() => _visible = false);
      });
    });
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

/// A calm, full-wordmark brand moment while the app comes up.
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
    // Broad enough to feel intentional on a phone, always inside the side
    // gutters on small ones, and capped so the wordmark stays balanced on
    // tablets and landscape screens.
    final logoWidth = math.min(MediaQuery.sizeOf(context).width * 0.86, 400.0);

    return Material(
      color: colors.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(top: -120, right: -80, child: _BrandGlow(size: 300)),
          const Positioned(
            bottom: -170,
            left: -110,
            child: _BrandGlow(size: 360),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 5),
                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _rise,
                    child: Semantics(
                      image: true,
                      label: 'Saints Link',
                      child: SizedBox(
                        width: logoWidth,
                        child: Image.asset(
                          'assets/brand/logo-light.png',
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                FadeTransition(opacity: _fade, child: const _RoadLoader()),
                const Spacer(flex: 4),
                FadeTransition(
                  opacity: _fade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A short stretch of the road from the wordmark's L, its centre-line
/// dashes travelling forward: on the way.
class _RoadLoader extends StatefulWidget {
  const _RoadLoader();

  @override
  State<_RoadLoader> createState() => _RoadLoaderState();
}

class _RoadLoaderState extends State<_RoadLoader>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 8,
      child: CustomPaint(painter: _RoadPainter(_controller)),
    );
  }
}

class _RoadPainter extends CustomPainter {
  _RoadPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  static const _dash = 8.0;
  static const _gap = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final road = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(road, Paint()..color = AppTheme.brand);

    // Dashes slide one period per cycle, so the loop is seamless. The road
    // fades out at both ends so they appear and vanish rather than pop.
    canvas.saveLayer(Offset.zero & size, Paint());
    final shift = progress.value * (_dash + _gap);
    final line = Paint()
      ..color = AppTheme.midnight
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    for (var x = shift - (_dash + _gap); x < size.width; x += _dash + _gap) {
      canvas.drawLine(Offset(x + 1, y), Offset(x + _dash - 1, y), line);
    }
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = const LinearGradient(
          colors: [
            Color(0x00FFFFFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0x00FFFFFF),
          ],
          stops: [0, 0.18, 0.82, 1],
        ).createShader(Offset.zero & size),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RoadPainter oldDelegate) => false;
}

class _BrandGlow extends StatelessWidget {
  const _BrandGlow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color(0x18FACC15), Color(0x00FACC15)],
          ),
        ),
      ),
    );
  }
}
