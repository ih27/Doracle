import 'dart:async';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:scrollable/exports.dart';
import 'package:typewritertext/typewritertext.dart';
import '../config/carousel_options.dart';
import '../config/theme.dart';
import '../mixins/shake_detector.dart';
import '../helpers/constants.dart';
import '../config/dependency_injection.dart';
import '../services/fortune_teller_service.dart';
import '../services/user_service.dart';
import '../services/haptic_service.dart';
import '../services/revenuecat_service.dart';
import '../widgets/sendable_textfield.dart';
import '../widgets/out_of_questions_overlay.dart';
import '../widgets/purchase_success_popup.dart';
import '../helpers/show_snackbar.dart';
import '../repositories/fortune_content_repository.dart';

class UnifiedFortuneScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final bool fromPurchase;

  const UnifiedFortuneScreen({
    super.key,
    required this.onNavigate,
    this.fromPurchase = false,
  });

  @override
  _UnifiedFortuneScreenState createState() => _UnifiedFortuneScreenState();
}

class _UnifiedFortuneScreenState extends State<UnifiedFortuneScreen>
    with ShakeDetectorMixin, WidgetsBindingObserver {
  final FortuneContentRepository _fortuneContentRepository =
      getIt<FortuneContentRepository>();
  final UserService _userService = getIt<UserService>();
  final HapticService _hapticService = getIt<HapticService>();
  final RevenueCatService _purchaseService = getIt<RevenueCatService>();
  final FortuneTeller _fortuneTeller = getIt<FortuneTeller>();
  final TextEditingController _questionController = TextEditingController();
  final FocusNode _questionFocusNode = FocusNode();

  late Future<void> _initializationFuture;
  bool isHome = true;
  bool _isKeyboardVisible = false;

  final String animationAsset = 'assets/animations/meraki_dog_rev5.riv';
  final String animationArtboard = 'meraki_dog';
  final String animationStateMachine = 'State Machine 1';

  late StateMachineController? _riveController;
  SMITrigger? _shakeInput;
  SMIBool? _processingInput;
  SMIBool? _listeningInput;

  late String _welcomeMessage;
  List<String> _randomQuestions = [];
  late TypeWriterController _fortuneController;
  bool _isFortuneCompleted = false;
  bool _isFortuneInProgress = false;
  final double _inputFieldFixedHeight = 66;

  Map<String, String> _cachedPrices = {};

  Future<void> _initialize() async {
    await Future.wait([
      _initializeFortuneTeller(),
      _fetchRandomQuestions(),
    ]);
    _welcomeMessage = _getRandomWelcomeMessage();
  }

  void _onUserServiceUpdate() {
    if (mounted) {
      _fetchPricesIfNeeded();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    initShakeDetector(onShake: _animateShake);
    _initializationFuture = _initialize();
    WidgetsBinding.instance.addObserver(this);
    _questionFocusNode.addListener(_handleFocusChange);
    _userService.addListener(_onUserServiceUpdate);
    // Set isHome to false if coming from a purchase
    if (widget.fromPurchase) {
      isHome = false;
    }
    // Initialize the controller with an empty stream
    _fortuneController = TypeWriterController.fromStream(const Stream.empty());
    _fetchPricesIfNeeded();
  }

  @override
  void dispose() {
    _disposeRiveController();
    _userService.removeListener(_onUserServiceUpdate);
    WidgetsBinding.instance.removeObserver(this);
    _questionController.dispose();
    _questionFocusNode.removeListener(_handleFocusChange);
    _questionFocusNode.dispose();
    _fortuneController.dispose();
    super.dispose();
  }

  void _disposeRiveController() {
    _riveController?.dispose();
    _riveController = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkKeyboardVisibility();
  }

  @override
  void didChangeMetrics() {
    // Schedule a check for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkKeyboardVisibility();
      }
    });
  }

  void _checkKeyboardVisibility() {
    if (!mounted) return;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final newIsKeyboardVisible = bottomInset > 0;
    if (newIsKeyboardVisible != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newIsKeyboardVisible;
      });
    }
  }

  String _getRandomWelcomeMessage() {
    final random = Random();
    return HomeScreenTexts
        .greetings[random.nextInt(HomeScreenTexts.greetings.length)];
  }

  Future<void> _fetchRandomQuestions() async {
    _randomQuestions = await _fortuneContentRepository.fetchRandomQuestions();
  }

  Future<void> _fetchPricesIfNeeded() async {
    if (_userService.hasRunOutOfQuestions() && _cachedPrices.isEmpty) {
      try {
        await _purchaseService.ensureInitialized();
        _cachedPrices = await _purchaseService.fetchPrices();
      } catch (e) {
        debugPrint('Error loading prices: $e');
        // Optionally, you could set a flag here to indicate that price fetching failed
        // This could be used to show a retry button or message in the UI if needed
      }
    }
  }

  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, animationStateMachine);
    artboard.addController(controller!);
    _riveController = controller;
    _shakeInput = controller.findInput<bool>('Shake') as SMITrigger;
    _processingInput = controller.findInput<bool>('Processing') as SMIBool;
    _listeningInput = controller.findInput<bool>('Listening') as SMIBool;
  }

  void _handleFocusChange() {
    if (_questionFocusNode.hasFocus) {
      _animateListeningStart();
    } else {
      _animateListeningDone();
    }
  }

  void _animateShake() {
    _shakeInput?.fire();
  }

  void _animateProcessingStart() {
    _processingInput?.change(true);
  }

  void _animateProcessingDone() {
    _processingInput?.change(false);
  }

  void _animateListeningStart() {
    _listeningInput?.change(true);
  }

  void _animateListeningDone() {
    _listeningInput?.change(false);
  }

  void _dismissKeyboard() {
    _questionFocusNode.unfocus();
  }

  void _onQuestionSubmitted(String question) {
    _dismissKeyboard();
    _getFortune(question);
  }

  Future<void> _initializeFortuneTeller() async {
    final personaData = await _fortuneContentRepository.getRandomPersona();
    setFortuneTellerPersona(
      personaData['name']!,
      personaData['instructions']!,
    );
  }

  void _showOutOfQuestionsOverlay() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (BuildContext dialogContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(dialogContext).size.width * 0.95,
              height: MediaQuery.of(dialogContext).size.height * 0.65,
              child: OutOfQuestionsOverlay(
                onClose: () => Navigator.of(dialogContext).pop(),
                onPurchase: (int questions) {
                  Navigator.of(dialogContext).pop();
                  _handlePurchase(questions);
                },
                prices: _cachedPrices,
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _handlePurchase(int questionCount) async {
    _animateProcessingStart();

    try {
      await _purchaseService.ensureInitialized();

      if (!await _purchaseService.purchaseProduct(questionCount)) {
        throw Exception('Purchase failed');
      }

      await _userService.updatePurchaseHistory(questionCount);
      _cachedPrices.clear();

      if (!mounted) return;
      Navigator.of(context).pop(); // Close the OutOfQuestionsOverlay

      showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return PurchaseSuccessPopup(
            questionCount: questionCount,
            onContinue: () {
              Navigator.of(buildContext).pop();
            },
          );
        },
      );
    } catch (e) {
      debugPrint('Purchase error: $e');
      if (mounted) {
        showErrorSnackBar(context, 'Purchase failed. Please try again.');
      }
    } finally {
      _animateProcessingDone();
    }
  }

  Future<void> _getFortune(String question) async {
    if (_userService.getRemainingQuestionsCount() <= 0) {
      _showOutOfQuestionsOverlay();
      _hapticService.warning();
      return;
    }

    if (question.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter a question.');
      _hapticService.error();
      return;
    }

    _hapticService.success();

    setState(() {
      _isFortuneInProgress = true;
      _isFortuneCompleted = false;
    });

    _animateProcessingStart();

    try {
      await _initializeFortuneTeller();

      final fortuneStreamController = StreamController<String>();

      _fortuneController =
          TypeWriterController.fromStream(fortuneStreamController.stream);

      const Duration charDelay = Duration(milliseconds: 5);
      String buffer = '';
      bool isTyping = false;

      void typeBuffer() async {
        isTyping = true;
        while (buffer.isNotEmpty) {
          if (!fortuneStreamController.isClosed) {
            // Ensure proper UTF-16 encoding
            String char = buffer.characters.first;
            fortuneStreamController.add(char);
            buffer = buffer.characters.skip(1).string;
            await Future.delayed(charDelay);
          } else {
            break;
          }
        }
        isTyping = false;
      }

      _fortuneTeller.getFortune(question).listen(
        (fortunePart) {
          buffer += fortunePart.characters.string;
          if (!isTyping) {
            typeBuffer();
          }
        },
        onDone: () async {
          while (buffer.isNotEmpty) {
            await Future.delayed(const Duration(milliseconds: 5));
          }
          setState(() {
            _isFortuneCompleted = true;
            _isFortuneInProgress = false;
          });
          _animateProcessingDone();
          await fortuneStreamController.close();
        },
        onError: (error) {
          fortuneStreamController.add('Unexpected error occurred');
          setState(() {
            _isFortuneCompleted = true;
            _isFortuneInProgress = false;
          });
          _animateProcessingDone();
        },
      );
    } catch (e) {
      _fortuneController = TypeWriterController.fromStream(
          Stream.value('Our puppy is not in the mood...'));
      setState(() {
        _isFortuneCompleted = true;
        _isFortuneInProgress = false;
      });
      _animateProcessingDone();
    }
  }

  Widget _buildContent() {
    if (isHome) {
      return _buildHomeContent();
    } else if (_isFortuneInProgress || _isFortuneCompleted) {
      return _buildFortuneContent();
    } else {
      return _buildQuestionSection();
    }
  }

  Widget _buildHomeContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
            child: Text(
              _welcomeMessage,
              textAlign: TextAlign.start,
              style: AppTheme.dogTextStyle,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: ElevatedButton(
            onPressed: () {
              setState(() => isHome = false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              minimumSize: const Size(0, 40),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Continue',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    letterSpacing: 0,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFortuneContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: TypeWriter(
                      controller: _fortuneController,
                      builder: (context, value) {
                        return SelectionArea(
                          child: Text(
                            value.text,
                            style: AppTheme.dogTextStyle,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isFortuneCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 22),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _questionController.clear();
                    _fortuneController =
                        TypeWriterController.fromStream(const Stream.empty());
                    _isFortuneCompleted = false;
                    _isFortuneInProgress = false;
                    _fetchRandomQuestions();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Ask Another Question',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        letterSpacing: 0,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimationContainer() {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: screenWidth * 0.75,
      child: RiveAnimation.asset(
        animationAsset,
        artboard: animationArtboard,
        fit: BoxFit.contain,
        onInit: _onRiveInit,
      ),
    );
  }

  Widget _buildQuestionSection() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final mediaQuery = MediaQuery.of(context);
        final bottomPadding = mediaQuery.padding.bottom;
        final bottomInset = mediaQuery.viewInsets.bottom;

        return Stack(
          children: [
            SizedBox(
              height: constraints.maxHeight -
                  _inputFieldFixedHeight -
                  bottomPadding,
              child: AnimatedOpacity(
                opacity: _isKeyboardVisible ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                child: _randomQuestions.isEmpty
                    ? Center(
                        child: Text(
                          'Type your question below',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _buildCarousel(),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: _isKeyboardVisible ? bottomInset : bottomPadding,
              child: _buildQuestionInput(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCarousel() {
    const double carouselItemHeight = 50;
    return ScrollHaptics(
        hapticEffectDuringScroll: HapticType.light,
        distancebetweenHapticEffectsDuringScroll: carouselItemHeight,
        child: CarouselSlider.builder(
          itemCount: _randomQuestions.length,
          itemBuilder: (context, index, _) {
            return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: IgnorePointer(
                  ignoring: _isKeyboardVisible,
                  child: ElevatedButton(
                    onPressed: () =>
                        _onQuestionSubmitted(_randomQuestions[index]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      minimumSize: const Size.fromHeight(carouselItemHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      _randomQuestions[index],
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ));
          },
          options: QuestionsSliderOptions(),
        ));
  }

  Widget _buildQuestionInput() {
    return Container(
      height: _inputFieldFixedHeight,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _userService.getRemainingQuestionsCount() == 0
                  ? _showOutOfQuestionsOverlay
                  : null,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: AppTheme.accent1,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Center(
                  child: Text(
                    '${_userService.getRemainingQuestionsCount()}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: SendableTextField(
                controller: _questionController,
                focusNode: _questionFocusNode,
                labelText: 'Ask what you want, passenger?',
                onSubmitted: _onQuestionSubmitted,
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              icon: Icon(Icons.send_rounded,
                  color: Theme.of(context).primaryColor),
              onPressed: () => _onQuestionSubmitted(_questionController.text),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.accent1,
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return GestureDetector(
            onTap: _dismissKeyboard,
            child: Column(
              children: [
                _buildAnimationContainer(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
