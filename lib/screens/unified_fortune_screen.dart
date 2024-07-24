import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../viewmodels/fortune_view_model.dart';
import '../mixins/fortune_animation_mixin.dart';
import '../mixins/shake_detector_mixin.dart';
import '../helpers/constants.dart';
import '../widgets/fortune_animation.dart';
import '../widgets/fortune_content.dart';
import '../widgets/home_content.dart';
import '../widgets/question_carousel.dart';
import '../widgets/question_input.dart';
import '../widgets/out_of_questions_overlay.dart';
import '../widgets/purchase_success_popup.dart';
import '../helpers/show_snackbar.dart';
import '../config/dependency_injection.dart';

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
    with ShakeDetectorMixin, WidgetsBindingObserver, FortuneAnimationMixin {
  late FortuneViewModel _viewModel;
  final TextEditingController _questionController = TextEditingController();
  final FocusNode _questionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<FortuneViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    initShakeDetector(onShake: animateShake);
    _viewModel.initialize();
    WidgetsBinding.instance.addObserver(this);
    _questionFocusNode.addListener(_handleFocusChange);
    if (widget.fromPurchase) {
      _viewModel.leaveHome();
    }
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    disposeRiveController();
    WidgetsBinding.instance.removeObserver(this);
    _questionController.dispose();
    _questionFocusNode.removeListener(_handleFocusChange);
    _questionFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkKeyboardVisibility();
  }

  @override
  void didChangeMetrics() {
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
    _viewModel.setKeyboardVisibility(newIsKeyboardVisible);
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

  Future<void> _handleQuestionSubmission(String question) async {
    if (_viewModel.getRemainingQuestionsCount() <= 0) {
      _showOutOfQuestionsOverlay();
      return;
    }

    if (question.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter a question.');
      return;
    }

    animateProcessingStart();
    await _viewModel.getFortune(question);
    animateProcessingDone();
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
                prices: _viewModel.cachedPrices,
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

    bool success = await _viewModel.handlePurchase(questionCount);
    if (mounted) {
      if (success) {
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
      } else {
        showErrorSnackBar(context, 'Purchase failed. Please try again.');
      }
    }

    animateProcessingDone();
  }

  Widget _buildContent() {
    if (_viewModel.isHome) {
      return HomeContent(
        welcomeMessage: _viewModel.welcomeMessage,
        onContinue: _viewModel.leaveHome,
      );
    } else if (_viewModel.isFortuneInProgress ||
        _viewModel.isFortuneCompleted) {
      return FortuneContent(
        fortuneController: _viewModel.fortuneController,
        isFortuneCompleted: _viewModel.isFortuneCompleted,
        onAskAnother: _viewModel.resetFortuneState,
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
                opacity: _viewModel.isKeyboardVisible ? 0.0 : 1.0,
                duration: FortuneConstants.carouselFadeoutDelay,
                curve: Curves.easeInOut,
                child: _viewModel.randomQuestions.isEmpty
                    ? Center(
                        child: Text(
                          'Type your question below',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : QuestionCarousel(
                        questions: _viewModel.randomQuestions,
                        onQuestionSelected: _onQuestionSubmitted,
                      ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom:
                  _viewModel.isKeyboardVisible ? bottomInset : bottomPadding,
              child: QuestionInput(
                controller: _questionController,
                focusNode: _questionFocusNode,
                onSubmitted: _onQuestionSubmitted,
                remainingQuestions: _viewModel.getRemainingQuestionsCount(),
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
      future: _viewModel.initialize(),
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

  void _initializeRiveController(Artboard artboard) {
    initializeRiveController(artboard, FortuneConstants.animationStateMachine);
  }
}
