import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

mixin ShakeDetectorMixin<T extends StatefulWidget> on State<T> {
  ShakeDetector? _shakeDetector;

  void initShakeDetector({
    required VoidCallback onShake,
    int minimumShakeCount = 1,
    int shakeSlopTimeMS = 500,
    int shakeCountResetTime = 3000,
    double shakeThresholdGravity = 2.7,
  }) {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: onShake,
      minimumShakeCount: minimumShakeCount,
      shakeSlopTimeMS: shakeSlopTimeMS,
      shakeCountResetTime: shakeCountResetTime,
      shakeThresholdGravity: shakeThresholdGravity,
    );
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    super.dispose();
  }
}