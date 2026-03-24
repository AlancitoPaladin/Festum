import 'dart:math' as math;

import 'package:flutter/material.dart';

class StaggeredAppear extends StatelessWidget {
  const StaggeredAppear({
    required this.index,
    required this.child,
    this.baseDelayMs = 40,
    this.maxExtraDelayMs = 320,
    super.key,
  });

  final int index;
  final int baseDelayMs;
  final int maxExtraDelayMs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final int extra = math.min(index * baseDelayMs, maxExtraDelayMs);
    final Duration duration = Duration(milliseconds: 240 + extra);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: child,
      builder: (BuildContext context, double value, Widget? child) {
        final double dy = (1 - value) * 14;
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, dy), child: child),
        );
      },
    );
  }
}
