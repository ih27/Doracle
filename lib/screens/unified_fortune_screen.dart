import 'dart:async';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:typewritertext/typewritertext.dart';
import '../mixins/fortune_animation_mixin.dart';
import '../mixins/shake_detector_mixin.dart';
import '../helpers/constants.dart';
import '../config/dependency_injection.dart';
import '../services/fortune_teller_service.dart';
import '../services/user_service.dart';
import '../services/haptic_service.dart';
import '../services/revenuecat_service.dart';
import '../widgets/fortune_animation.dart';
import '../widgets/fortune_content.dart';
import '../widgets/home_content.dart';
import '../widgets/question_carousel.dart';
import '../widgets/question_input.dart';
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
    with ShakeDetectorMixin, FortuneAnimationMixin, WidgetsBindingObserver {
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

  late String _welcomeMessage;
  List<String> _randomQuestions = [];
  late TypeWriterController _fortuneController;
  bool _isFortuneCompleted = false;
  bool _isFortuneInProgress = false;

  Map<String, String> _cachedPrices = {};

  void _initializeRiveController(Artboard artboard) {
    initializeRiveController(artboard, FortuneConstants.animationStateMachine);
  }

  Future<void> _initializeApp() async {
    await Future.wait([
      _initializeFortuneTeller(),
      _fetchRandomQuestions(),
    ]);
    _welcomeMessage = _getRandomWelcomeMessage();
  }

  Future<void> _handleQuestionSubmission(String question) async {
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
    await _getFortune(question);
  }

  Future<void> _getFortune(String question) async {
    setState(() {
      _isFortuneInProgress = true;
      _isFortuneCompleted = false;
    });

    animateProcessingStart();

    try {
      await _initializeFortuneTeller();
      await _fetchAndDisplayFortune(question);
    } catch (e) {
      _handleFortuneError();
    }
  }

  Future<void> _fetchAndDisplayFortune(String question) async {
    final fortuneStreamController = StreamController<String>();
    _fortuneController =
        TypeWriterController.fromStream(fortuneStreamController.stream);

    String buffer = '';
    bool isTyping = false;

    void typeBuffer() async {
      isTyping = true;
      while (buffer.isNotEmpty) {
        if (!fortuneStreamController.isClosed) {
          String char = buffer.characters.first;
          fortuneStreamController.add(char);
          buffer = buffer.characters.skip(1).string;
          await Future.delayed(FortuneConstants.charDelay);
        } else {
          break;
        }
      }
      isTyping = false;
    }

    _fortuneTeller.getFortune(question).listen(
          (fortunePart) =>
              _handleFortunePart(fortunePart, buffer, isTyping, typeBuffer),
          onDone: () => _handleFortuneDone(buffer, fortuneStreamController),
          onError: (error) => _handleFortuneError(),
        );
  }

  void _handleFortunePart(
      String fortunePart, String buffer, bool isTyping, Function typeBuffer) {
    buffer += fortunePart.characters.string;
    if (!isTyping) {
      typeBuffer();
    }
  }

  Future<void> _handleFortuneDone(
      String buffer, StreamController<String> fortuneStreamController) async {
    while (buffer.isNotEmpty) {
      await Future.delayed(FortuneConstants.charDelay);
    }
    setState(() {
      _isFortuneCompleted = true;
      _isFortuneInProgress = false;
    });
    animateProcessingDone();
    await fortuneStreamController.close();
  }

  void _handleFortuneError() {
    _fortuneController = TypeWriterController.fromStream(
        Stream.value('Our puppy is not in the mood...'));
    setState(() {
      _isFortuneCompleted = true;
      _isFortuneInProgress = false;
    });
    animateProcessingDone();
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
    initShakeDetector(onShake: animateShake);
    _initializationFuture = _initializeApp();
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
    disposeRiveController();
    _userService.removeListener(_onUserServiceUpdate);
    WidgetsBinding.instance.removeObserver(this);
    _questionController.dispose();
    _questionFocusNode.removeListener(_handleFocusChange);
    _questionFocusNode.dispose();
    _fortuneController.dispose();
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
    _randomQuestions = await _fortuneContentRepository.fetchRandomQuestions();
  }

  Future<void> _fetchPricesIfNeeded() async {
    if (_userService.hasRunOutOfQuestions() && _cachedPrices.isEmpty) {
      try {
        await _purchaseService.ensureInitialized();
        _cachedPrices = await _purchaseService.fetchPrices();
      } catch (e) {
        debugPrint('Error loading prices: $e');
      }
    }
  }

  void _handleFocusChange() {
    if (_questionFocusNode.hasFocus) {
      animateListeningStart();
    } else {
      animateListeningDone();
    }
  }

  void _dismissKeyboard() {
    _questionFocusNode.unfocus();
  }

  void _onQuestionSubmitted(String question) {
    _dismissKeyboard();
    _handleQuestionSubmission(question);
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
      transitionDuration: FortuneConstants.outOfQuestionsPopupDelay,
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
    animateProcessingStart();

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
      animateProcessingDone();
    }
  }

  void _resetFortuneState() {
    setState(() {
      _questionController.clear();
      _fortuneController =
          TypeWriterController.fromStream(const Stream.empty());
      _isFortuneCompleted = false;
      _isFortuneInProgress = false;
      _fetchRandomQuestions();
    });
  }

  Widget _buildContent() {
    if (isHome) {
      return HomeContent(
        welcomeMessage: _welcomeMessage,
        onContinue: () => setState(() => isHome = false),
      );
    } else if (_isFortuneInProgress || _isFortuneCompleted) {
      return FortuneContent(
        fortuneController: _fortuneController,
        isFortuneCompleted: _isFortuneCompleted,
        onAskAnother: _resetFortuneState,
      );
    } else {
      return _buildQuestionSection();
    }
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
                  FortuneConstants.inputFieldFixedHeight -
                  bottomPadding,
              child: AnimatedOpacity(
                opacity: _isKeyboardVisible ? 0.0 : 1.0,
                duration: FortuneConstants.carouselFadeoutDelay,
                curve: Curves.easeInOut,
                child: _randomQuestions.isEmpty
                    ? Center(
                        child: Text(
                          'Type your question below',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : QuestionCarousel(
                        questions: _randomQuestions,
                        onQuestionSelected: _onQuestionSubmitted,
                      ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: _isKeyboardVisible ? bottomInset : bottomPadding,
              child: QuestionInput(
                controller: _questionController,
                focusNode: _questionFocusNode,
                onSubmitted: _onQuestionSubmitted,
                remainingQuestions: _userService.getRemainingQuestionsCount(),
                onShowOutOfQuestions: _showOutOfQuestionsOverlay,
              ),
            ),
          ],
        );
      },
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
                FortuneAnimation(onInit: _initializeRiveController),
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
