import 'package:flutter/material.dart';

class TapGuardView extends StatefulWidget {
  const TapGuardView({
    super.key,
    required this.child,
    this.onPressed,
    this.cooldown = const Duration(milliseconds: 800),
    this.borderRadius,
    this.enableFeedback = true,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Duration cooldown;
  final BorderRadius? borderRadius;
  final bool enableFeedback;

  @override
  State<TapGuardView> createState() => _TapGuardState();
}

class _TapGuardState extends State<TapGuardView> {
  final Stopwatch cooldownClock = Stopwatch();

  void handlePressed() {
    if (cooldownClock.isRunning && cooldownClock.elapsed < widget.cooldown) {
      return;
    }
    cooldownClock
      ..reset()
      ..start();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed == null ? null : handlePressed,
      borderRadius: widget.borderRadius,
      enableFeedback: widget.enableFeedback,
      child: widget.child,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
