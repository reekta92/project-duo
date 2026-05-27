import 'package:flutter/material.dart';

/// Zen animation constants and page transitions.
abstract class ZenAnimations {
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationXSlow = Duration(milliseconds: 800);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;

  /// Fade + subtle vertical slide page transition.
  static Route<T> fadeSlideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, anim, __) => page,
      transitionsBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: curve)),
            child: child,
          ),
        );
      },
      transitionDuration: durationNormal,
    );
  }

  /// Scale animation for card taps.
  static Widget scaleTap({
    required Widget child,
    required VoidCallback? onTap,
  }) {
    return _ScaleTapWidget(onTap: onTap, child: child);
  }

  static Widget breathingAnimation({required Widget child}) {
    return _BreathingWidget(child: child);
  }

  static Widget staggeredEntrance({
    required int index,
    required Widget child,
  }) {
    return _StaggeredEntranceWidget(index: index, child: child);
  }
}

class _StaggeredEntranceWidget extends StatefulWidget {
  final int index;
  final Widget child;
  const _StaggeredEntranceWidget({required this.index, required this.child});

  @override
  State<_StaggeredEntranceWidget> createState() => _StaggeredEntranceWidgetState();
}

class _StaggeredEntranceWidgetState extends State<_StaggeredEntranceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
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
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

class _ScaleTapWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _ScaleTapWidget({required this.child, required this.onTap});

  @override
  State<_ScaleTapWidget> createState() => _ScaleTapWidgetState();
}

class _ScaleTapWidgetState extends State<_ScaleTapWidget> {
  bool _scaled = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scaled = true),
      onTapUp: (_) => setState(() => _scaled = false),
      onTapCancel: () => setState(() => _scaled = false),
      child: AnimatedScale(
        scale: _scaled ? 0.97 : 1.0,
        duration: ZenAnimations.durationFast,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _BreathingWidget extends StatefulWidget {
  final Widget child;
  const _BreathingWidget({required this.child});

  @override
  State<_BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<_BreathingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: widget.child,
    );
  }
}
