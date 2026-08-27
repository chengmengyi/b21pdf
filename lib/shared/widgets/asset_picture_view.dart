import 'package:flutter/material.dart';

class AssetPictureView extends StatelessWidget {
  const AssetPictureView(
    this.fileName, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.tintColor,
    this.semanticLabel,
    this.excludeSemantics = false,
  });

  static const String assetRoot = 'assets/images/';

  final String fileName;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final Color? tintColor;
  final String? semanticLabel;
  final bool excludeSemantics;

  String get assetPath => '$assetRoot$fileName.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit ?? BoxFit.fill,
      alignment: alignment,
      color: tintColor,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeSemantics,
    );
  }
}
