import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizedTextView extends StatelessWidget {
  const LocalizedTextView(
    this.value, {
    super.key,
    this.translate = false,
    this.style,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.decoration,
  });

  final String value;
  final bool translate;
  final TextStyle? style;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final TextStyle resolvedStyle = (style ?? const TextStyle()).copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: decoration,
      decorationColor: color,
    );
    return Text(
      translate ? value.tr : value,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      style: resolvedStyle,
    );
  }
}
