import 'package:rive/rive.dart';

mixin FortuneAnimationMixin {
  StateMachineController? riveController;
  SMITrigger? shakeInput;
  SMIBool? processingInput;
  SMIBool? listeningInput;

  void initializeRiveController(Artboard artboard, String stateMachineName) {
    final controller =
        StateMachineController.fromArtboard(artboard, stateMachineName);
    artboard.addController(controller!);
    riveController = controller;
    shakeInput = controller.findInput<bool>('Shake') as SMITrigger;
    processingInput = controller.findInput<bool>('Processing') as SMIBool;
    listeningInput = controller.findInput<bool>('Listening') as SMIBool;
  }

  void animateShake() {
    shakeInput?.fire();
  }

  void animateProcessingStart() {
    processingInput?.change(true);
  }

  void animateProcessingDone() {
    processingInput?.change(false);
  }

  void animateListeningStart() {
    listeningInput?.change(true);
  }

  void animateListeningDone() {
    listeningInput?.change(false);
  }

  void disposeRiveController() {
    riveController?.dispose();
    riveController = null;
  }
}
