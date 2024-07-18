import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../config/theme.dart';
import '../mixins/shake_detector.dart';
import '../helpers/constants.dart';
import '../config/dependency_injection.dart';
import '../services/question_cache_service.dart';
import '../services/user_service.dart';
import '../services/haptic_service.dart';
import '../services/revenuecat_service.dart';
import '../widgets/sendable_textfield.dart';
import '../widgets/out_of_questions_overlay.dart';
import '../widgets/purchase_success_popup.dart';
import '../controllers/fortune_teller.dart';
import '../helpers/show_snackbar.dart';
import '../repositories/fortune_content_repository.dart';

class UnifiedFortuneScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const UnifiedFortuneScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  _UnifiedFortuneScreenState createState() => _UnifiedFortuneScreenState();
}

class _UnifiedFortuneScreenState extends State<UnifiedFortuneScreen>
    with ShakeDetectorMixin, WidgetsBindingObserver {
  final QuestionCacheService _questionCacheService =
      getIt<QuestionCacheService>();
  final UserService _userService = getIt<UserService>();
  final HapticService _hapticService = getIt<HapticService>();
  final RevenueCatService _purchaseService = getIt<RevenueCatService>();
  final FortuneTeller _fortuneTeller = getIt<FortuneTeller>();
  final TextEditingController _questionController = TextEditingController();

  late Future<void> _initializationFuture;
  bool isHome = true;
  bool _showBottomUI = true;
  bool _isKeyboardVisible = false;

  final String animationAsset = 'assets/animations/meraki_dog_rev3.riv';
  final String animationArtboard = 'meraki_dog';
  final String animationStateMachine = 'State Machine 1';

  SMITrigger? _shakeInput;
  SMIBool? _processingInput;

  late String _welcomeMessage;
  List<String> _randomQuestions = [];
  List<TextSpan> _fortuneSpans = [];
  bool _isFortuneCompleted = false;
  final double _inputFieldFixedHeight = 66;

  @override
  void initState() {
    super.initState();
    initShakeDetector(onShake: _animateShake);
    _initializationFuture = _initialize();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initialize() async {
    await Future.wait([
      _initializeFortuneTeller(),
      _fetchRandomQuestions(),
    ]);
    _welcomeMessage = _getRandomWelcomeMessage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _questionController.dispose();
    super.dispose();
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
    _randomQuestions = await _questionCacheService.getRandomQuestions();
  }

  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, animationStateMachine);
    artboard.addController(controller!);
    _shakeInput = controller.findInput<bool>('Shake') as SMITrigger;
    _processingInput = controller.findInput<bool>('Processing') as SMIBool;
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

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _onQuestionSubmitted(String question) {
    _dismissKeyboard();
    _getFortune(question);
  }

  Future<void> _initializeFortuneTeller() async {
    final personaData =
        await getIt<FortuneContentRepository>().getRandomPersona();
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
      if (!await _purchaseService.purchaseProduct(questionCount)) {
        _animateProcessingDone();
        return;
      }

      await _userService.updatePurchaseHistory(questionCount);

      _animateProcessingDone();

      if (!mounted) return;
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
      _animateProcessingDone();
      if (mounted) {
        showErrorSnackBar(context, 'Purchase failed. Please try again.');
      }
    }
  }

  void _hideBottomUI() {
    setState(() {
      _showBottomUI = false;
    });
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
    _hideBottomUI();

    setState(() {
      _isFortuneCompleted = false;
      _fortuneSpans = [];
    });

    _animateProcessingStart();

    try {
      await _initializeFortuneTeller();
      bool isFirstChunk = true;
      _fortuneTeller.getFortune(question).listen(
        (fortunePart) {
          setState(() {
            if (isFirstChunk) {
              isFirstChunk = false;
            }
            _fortuneSpans = List.from(_fortuneSpans)
              ..add(TextSpan(text: fortunePart));
          });
        },
        onDone: () async {
          setState(() {
            _isFortuneCompleted = true;
          });
          _animateProcessingDone();
        },
        onError: (error) {
          setState(() {
            _fortuneSpans = List.from(_fortuneSpans)
              ..add(const TextSpan(text: 'Unexpected error occurred'));
            _isFortuneCompleted = true;
          });
          _animateProcessingDone();
        },
      );
    } catch (e) {
      setState(() {
        _fortuneSpans = List.from(_fortuneSpans)
          ..add(const TextSpan(text: 'Our puppy is not in the mood...'));
        _isFortuneCompleted = true;
      });
      _animateProcessingDone();
    }
  }

  Widget _buildContent() {
    if (isHome) {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
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
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: _fortuneSpans.isEmpty
            ? _showBottomUI
                ? _buildQuestionSection()
                : const SizedBox.shrink()
            : _buildAnswerSection(),
      );
    }
  }

  Widget _buildAnimationContainer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.width * 0.7,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
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
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: _isKeyboardVisible,
                  child: _buildCarousel(),
                ),
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
    return CarouselSlider.builder(
      itemCount: _randomQuestions.length,
      itemBuilder: (context, index, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ElevatedButton(
            onPressed: () => _onQuestionSubmitted(_randomQuestions[index]),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              minimumSize: const Size.fromHeight(50),
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
        );
      },
      options: CarouselOptions(
        height: double.infinity,
        viewportFraction: 0.2,
        enableInfiniteScroll: true,
        scrollDirection: Axis.vertical,
        enlargeCenterPage: true,
        enlargeFactor: 0.25,
      ),
    );
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

  Widget _buildAnswerSection() {
    return Column(
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
                  child: SelectionArea(
                    child: RichText(
                      text: TextSpan(
                        children: _fortuneSpans,
                        style: AppTheme.dogTextStyle,
                      ),
                    ),
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
                  _fortuneSpans = [];
                  _isFortuneCompleted = false;
                  _showBottomUI = true;
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
