import 'package:flutter/material.dart';

/// Holds every tab's navigator, showing one at a time. A switch plays the
/// same zoom the page transitions use: the new tab scales up and fades in
/// over the old one, which drifts back until it is covered. Hidden tabs stay mounted, so scroll
/// positions and form state survive, and their tickers are paused.
class ZoomTabContainer extends StatefulWidget {
  const ZoomTabContainer({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<ZoomTabContainer> createState() => _ZoomTabContainerState();
}

class _ZoomTabContainerState extends State<ZoomTabContainer>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    // The same numbers as Flutter's ZoomPageTransition, so a tab switch and
    // a page push read as one motion.
    duration: const Duration(milliseconds: 300),
    value: 1,
  );
  late final _enterFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.3, curve: Curves.easeOut),
  );
  late final _enterScale = Tween(
    begin: 0.85,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  late final _exitScale = Tween(
    begin: 1.0,
    end: 1.05,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  int? _leaving;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _leaving != null) {
        setState(() => _leaving = null);
      }
    });
  }

  @override
  void didUpdateWidget(ZoomTabContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _leaving = oldWidget.index;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The leaving tab is painted first so the incoming one zooms in over it;
    // otherwise the scaffold shows around the still-small incoming tab as
    // white edges. go_router keys every branch, so reordering keeps state.
    final order = [
      for (var i = 0; i < widget.children.length; i++)
        if (i != widget.index) i,
      widget.index,
    ];
    return Stack(
      fit: StackFit.expand,
      children: [for (final i in order) _tab(i, widget.children[i])],
    );
  }

  Widget _tab(int i, Widget child) {
    final active = i == widget.index;
    final leaving = i == _leaving;
    Widget body = child;
    if (active) {
      body = FadeTransition(
        opacity: _enterFade,
        child: ScaleTransition(scale: _enterScale, child: body),
      );
    } else if (leaving) {
      // Stays opaque underneath; the incoming tab covers it as it grows.
      body = IgnorePointer(
        child: ScaleTransition(scale: _exitScale, child: body),
      );
    }
    return Offstage(
      offstage: !active && !leaving,
      child: TickerMode(enabled: active, child: body),
    );
  }
}
