import 'package:flutter/material.dart';

class MediaPaddingView extends StatelessWidget {
  const MediaPaddingView({
    super.key,
    required this.child,
    this.removeTop = true,
    this.removeBottom = true,
    this.removeLeft = true,
    this.removeRight = true,
  });

  final Widget child;
  final bool removeTop;
  final bool removeBottom;
  final bool removeLeft;
  final bool removeRight;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: removeTop,
      removeBottom: removeBottom,
      removeLeft: removeLeft,
      removeRight: removeRight,
      child: child,
    );
  }
}
