import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieWidget extends StatelessWidget {
  String name;
  double? width;
  double? height;
  BoxFit? boxFit;
  bool? repeat;
  LottieWidget({required this.name, this.width, this.height, this.repeat});

  @override
  Widget build(BuildContext context) => Lottie.asset(
    "assets/pdf_animation_bundle/$name.json",
    width: width,
    height: height,
    fit: boxFit,
    repeat: repeat ?? false,
  );
}
