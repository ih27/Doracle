import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:typewritertext/typewritertext.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../helpers/purchase_utils.dart';
import '../viewmodels/fortune_view_model.dart';
import '../mixins/fortune_animation_mixin.dart';
import '../mixins/shake_detector_mixin.dart';
import '../helpers/constants.dart';
import '../widgets/fortune_animation.dart';
import '../widgets/fortune_content.dart';
import '../widgets/oracle_home_content.dart';
import '../widgets/question_carousel.dart';
import '../widgets/question_input.dart';
import '../widgets/out_of_questions_overlay.dart';
import '../widgets/purchase_success_popup.dart';
import '../helpers/show_snackbar.dart';
import '../config/dependency_injection.dart';
import '../services/unified_analytics_service.dart';
import '../services/connectivity_service.dart';

class UnifiedFortuneScreen extends StatefulWidget {
  final bool fromPurchase;

  const UnifiedFortuneScreen({
    super.key,
    this.fromPurchase = false,
  });

  @override
  _UnifiedFortuneScreenState createState() => _UnifiedFortuneScreenState();
}

class _UnifiedFortuneScreenState extends State<UnifiedFortuneScreen>
    with ShakeDetectorMixin, FortuneAnimationMixin {
  late FortuneViewModel _viewModel;
  final TextEditingController _questionController = TextEditingController();
  final FocusNode _questionFocusNode = FocusNode();
  final UnifiedAnalyticsService _analytics = getIt<UnifiedAnalyticsService>();
  final ConnectivityService _connectivityService = getIt<ConnectivityService>();

  bool _isFortuneInProgress = false;
  bool _isFortuneCompleted = false;
  bool _isKeyboardVisible = false;
  late TypeWriterController _fortuneController;
  late StreamSubscription<bool> _keyboardSubscription;
  bool _isConnected = true;
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<FortuneViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    initShakeDetector(onShake: animateShake);
    _viewModel.initialize();
    _questionFocusNode.addListener(_handleFocusChange);
    if (widget.fromPurchase) {
      _viewModel.leaveHome();
    }
    _fortuneController = TypeWriterController.fromStream(const Stream.empty());

    // Track screen view
    _analytics.logScreenView(screenName: 'fortune_screen');

    // Initialize keyboard visibility listener
    final keyboardVisibilityController = KeyboardVisibilityController();
    _keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        _isKeyboardVisible = visible;
      });
    });

    // Listen for connectivity changes
    _connectivityService.isConnected().then((connected) {
      setState(() {
        _isConnected = connected;
        if (!connected) {
          showErrorSnackBar(context,
              'No internet connection. Please check your network settings.');
        }
      });
    });

    _connectivitySubscription =
        _connectivityService.connectionStatusStream.listen((connected) {
      setState(() {
        bool wasConnected = _isConnected;
        _isConnected = connected;

        // Only show SnackBar when connection status changes
        if (!connected && wasConnected) {
          showErrorSnackBar(context,
              'Network connection lost. Please check your internet and try again.');
        } else if (connected && !wasConnected) {
          showInfoSnackBar(context, 'Internet connection restored.');
        }

        if (!connected && _isFortuneInProgress) {
          _isFortuneInProgress = false;
          _isFortuneCompleted = true;
          animateProcessingDone();
        }
      });
    });
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
    _questionController.dispose();
    _questionFocusNode.removeListener(_handleFocusChange);
    _questionFocusNode.dispose();
    _fortuneController.dispose();
    _keyboardSubscription.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
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
    if (!_viewModel.canAskQuestion()) {
      _showIAPOverlay();
      return;
    }

    if (question.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter a question.');
      return;
    }

    setState(() {
      _isFortuneInProgress = true;
      _isFortuneCompleted = false;
      animateProcessingStart();
    });

    await _getFortune(question);
  }

  void _handleAskAnother() {
    _questionController.text = '';
    setState(() {
      _isFortuneCompleted = false;
      _isFortuneInProgress = false;
    });
    _viewModel.resetFortuneState();
  }

  Future<void> _getFortune(String question) async {
    final fortuneStreamController = StreamController<String>();
    _fortuneController =
        TypeWriterController.fromStream(fortuneStreamController.stream);

    String buffer = '';
    bool isTyping = false;

    // Add a timeout to prevent hanging indefinitely
    bool hasTimedOut = false;
    Future.delayed(const Duration(seconds: 30)).then((_) {
      if (!fortuneStreamController.isClosed &&
          _isFortuneInProgress &&
          !_isFortuneCompleted) {
        hasTimedOut = true;
        fortuneStreamController.add(
            '\n\nUh oh! The connection timed out. Please check your internet connection and try again.');
        setState(() {
          _isFortuneCompleted = true;
          _isFortuneInProgress = false;
          animateProcessingDone();
        });
      }
    });

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

    try {
      _viewModel.getFortune(question).listen(
        (fortunePart) {
          buffer += fortunePart;
          if (!isTyping) {
            typeBuffer();
          }
        },
        onDone: () async {
          // Only process if we haven't already timed out
          if (!hasTimedOut) {
            while (buffer.isNotEmpty) {
              await Future.delayed(FortuneConstants.charDelay);
            }
            if (mounted) {
              setState(() {
                _isFortuneCompleted = true;
                _isFortuneInProgress = false;
                animateProcessingDone();
              });
            }
            await fortuneStreamController.close();
          }
        },
        onError: (error) {
          // Create a user-friendly error message
          String errorMessage =
              '\n\nSorry, I couldn\'t connect to my crystal ball. Please check your internet connection and try again.';
          fortuneStreamController.add(errorMessage);

          if (mounted) {
            setState(() {
              _isFortuneCompleted = true;
              _isFortuneInProgress = false;
              animateProcessingDone();
            });
          }
        },
      );
    } catch (e) {
      // Catch any other exceptions that might occur
      String errorMessage =
          '\n\nSorry, something went wrong. Please try again later.';
      fortuneStreamController.add(errorMessage);

      if (mounted) {
        setState(() {
          _isFortuneCompleted = true;
          _isFortuneInProgress = false;
          animateProcessingDone();
        });
      }
    }
  }

  void _showIAPOverlay() {
    showCustomOverlay<int>(
      context: context,
      heightFactor: 0.65,
      overlayBuilder: (dialogContext, close) => OutOfQuestionsOverlay(
        onClose: close,
        onPurchase: (int questions) {
          close();
          _handlePurchase(questions);
        },
        prices: _viewModel.cachedPrices,
      ),
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
      return OracleHomeContent(
        welcomeMessage: _viewModel.welcomeMessage,
        onContinuePressed: _viewModel.leaveHome,
      );
    } else if (_isFortuneInProgress || _isFortuneCompleted) {
      return FortuneContent(
        fortuneController: _fortuneController,
        isFortuneCompleted: _isFortuneCompleted,
        onAskAnother: _handleAskAnother,
      );
    } else {
      return _buildQuestionSection();
    }
  }

  Widget _buildQuestionSection() {
    return Column(
      children: [
        Expanded(
          child: !_isKeyboardVisible
              ? _viewModel.randomQuestions.isEmpty
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
                    )
              : const SizedBox.shrink(),
        ),
        QuestionInput(
          controller: _questionController,
          focusNode: _questionFocusNode,
          onSubmitted: _onQuestionSubmitted,
          remainingQuestions: _viewModel.getRemainingQuestionsCount(),
          isSubscribed: _viewModel.isSubscribed,
          onShowOutOfQuestions:
              _viewModel.isSubscribed ? null : _showIAPOverlay,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isKeyboardVisible ? _dismissKeyboard : null,
      behavior: HitTestBehavior.opaque,
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

  void _initializeRiveController(Artboard artboard) {
    initializeRiveController(artboard, FortuneConstants.animationStateMachine);
  }
}
