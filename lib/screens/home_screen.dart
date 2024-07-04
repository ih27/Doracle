import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../mixins/shake_detector.dart';
import '../repositories/firestore_user_repository.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(String) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with ShakeDetectorMixin {
  final UserService userService = UserService(FirestoreUserRepository());
  bool isLoading = true;
  String? errorMessage;

  SMITrigger? _shakeInput;

  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
    artboard.addController(controller!);
    _shakeInput = controller.findInput<bool>('Shake') as SMITrigger;
  }

  void _shake() {
    _shakeInput?.fire();
  }

  @override
  void initState() {
    super.initState();
    initShakeDetector(onShake: () => _shake());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: RiveAnimation.asset(
                    'assets/animations/meraki_dog.riv',
                    artboard: 'meraki_dog',
                    fit: BoxFit.contain,
                    onInit: _onRiveInit,
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: AutoSizeText(
                      'Hey, stranger!\n\nI\'m Doracle, your AI Oracle. What guidance do you seek?',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => widget.onNavigate('/fortune'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 0),
                      minimumSize:
                          const Size(0, 40), // Set minimum height to 40
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      'Continue',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontFamily: 'Roboto',
                            color: Colors.white,
                            letterSpacing: 0,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
