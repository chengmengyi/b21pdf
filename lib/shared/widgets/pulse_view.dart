import 'package:flutter/material.dart';

class PulseView extends StatefulWidget {
  const PulseView({
    super.key,
    required this.child,
    this.lowerScale = 0.96,
    this.upperScale = 1,
    this.cycleDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
  }) : assert(lowerScale > 0),
       assert(lowerScale <= upperScale),
       assert(cycleDuration > Duration.zero);

  final Widget child;
  final double lowerScale;
  final double upperScale;
  final Duration cycleDuration;
  final Curve curve;

  @override
  State<PulseView> createState() => _PulseViewState();
}

class _PulseViewState extends State<PulseView>
    with SingleTickerProviderStateMixin {
  late final AnimationController motionController;
  late Animation<double> scaleMotion;
  bool animationsDisabled = false;

  @override
  void initState() {
    super.initState();
    motionController = AnimationController(
      vsync: this,
      duration: widget.cycleDuration,
    );
    updateAnimationAccessibility();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool disableMotion = MediaQuery.disableAnimationsOf(context);
    if (disableMotion == animationsDisabled) {
      return;
    }
    animationsDisabled = disableMotion;
    syncAnimationPlayback();
  }

  @override
  void didUpdateWidget(covariant PulseView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cycleDuration != widget.cycleDuration) {
      motionController.duration = widget.cycleDuration;
    }
    if (oldWidget.lowerScale != widget.lowerScale ||
        oldWidget.upperScale != widget.upperScale ||
        oldWidget.curve != widget.curve) {
      updateAnimationAccessibility();
    }
  }

  void updateAnimationAccessibility() {
    scaleMotion = Tween<double>(
      begin: widget.lowerScale,
      end: widget.upperScale,
    ).animate(CurvedAnimation(parent: motionController, curve: widget.curve));
    syncAnimationPlayback();
  }

  void syncAnimationPlayback() {
    if (animationsDisabled) {
      motionController.stop();
      motionController.value = 1;
    } else if (!motionController.isAnimating) {
      motionController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: scaleMotion, child: widget.child);
  }
}
