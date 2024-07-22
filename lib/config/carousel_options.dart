import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CustomScrollPhysics extends ScrollPhysics {
  static final SpringDescription customSpring =
      SpringDescription.withDampingRatio(mass: 50, stiffness: 5, ratio: 10);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics();
  }

  @override
  SpringDescription get spring => customSpring;
}

class QuestionsSliderOptions extends CarouselOptions {
  @override
  double? get height => double.infinity;

  @override
  double get viewportFraction => 0.2;

  @override
  Axis get scrollDirection => Axis.vertical;

  @override
  bool? get enlargeCenterPage => true;

  @override
  double get enlargeFactor => 0.25;

  @override
  ScrollPhysics? get scrollPhysics => CustomScrollPhysics();

  @override
  Clip get clipBehavior => Clip.antiAlias;
}
