import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

class ConditionalBlur extends StatelessWidget {
  final Widget child;
  final bool blur;
  final double blurAmount;
  final int blurDuration;

  const ConditionalBlur({
    super.key,
    required this.child,
    required this.blur,
    this.blurAmount = 3.0,
    this.blurDuration = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: blurDuration),
      child: blur
          ? ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: blurAmount,
                sigmaY: blurAmount,
              ),
              child: child,
            )
          : child,
    );
  }
}
