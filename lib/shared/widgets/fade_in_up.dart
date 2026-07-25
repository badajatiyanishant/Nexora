import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Fades and slides its child in on first build.
///
/// Staggering [delay] across a list gives the cascading entrance used by
/// premium dashboards. Purely decorative — never gates content visibility on
/// animation completing.
class FadeInUp extends StatefulWidget {
  const FadeInUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.normal,
    this.offset = 24,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Vertical travel in logical pixels.
  final double offset;

  /// Convenience for building staggered lists.
  static Duration stagger(int index, {int step = 60, int max = 400}) =>
      Duration(milliseconds: (index * step).clamp(0, max));

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: Offset(0, widget.offset / 100),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: _controller, curve: AppMotion.emphasized),
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay).then((_) {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
