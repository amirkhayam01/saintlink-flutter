import 'package:flutter/material.dart';

import '../core/theme.dart';

/// A shimmering placeholder in the shape of the content that is coming.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, required this.child});

  /// Any tree made of [SkeletonBox]es laid out like the real content.
  final Widget child;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: 0.55 + 0.45 * (0.5 + 0.5 * -_cos(_controller.value)),
        child: child,
      ),
      child: widget.child,
    );
  }

  static double _cos(double t) =>
      (t * 2 - 1).abs() * 2 - 1; // triangle wave in [-1, 1]
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 6});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.inkFaint,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Three trip-card-shaped placeholders for the trips list.
class TripListSkeleton extends StatelessWidget {
  const TripListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Skeleton(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.inkFaint),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 56, height: 68, radius: 12),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SkeletonBox(width: 60, height: 16),
                        Spacer(),
                        SkeletonBox(width: 80, height: 22, radius: 999),
                      ],
                    ),
                    SizedBox(height: 14),
                    SkeletonBox(width: 200),
                    SizedBox(height: 10),
                    SkeletonBox(width: 170),
                    SizedBox(height: 14),
                    Row(
                      children: [
                        SkeletonBox(width: 120),
                        Spacer(),
                        SkeletonBox(width: 60, height: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
