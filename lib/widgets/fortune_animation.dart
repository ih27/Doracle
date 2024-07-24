import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart';

import '../helpers/constants.dart';

class FortuneAnimation extends StatelessWidget {
  final Function(Artboard) onInit;

  const FortuneAnimation({super.key, required this.onInit});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: screenWidth * 0.75,
      child: RiveAnimation.asset(
        FortuneConstants.animationAsset,
        artboard: FortuneConstants.animationArtboard,
        fit: BoxFit.contain,
        onInit: onInit,
      ),
    );
  }
}
