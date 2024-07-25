import 'dart:async';
import 'package:flutter/material.dart';
import 'package:typewritertext/typewritertext.dart';
import '../services/fortune_teller_service.dart';
import '../services/user_service.dart';
import '../services/haptic_service.dart';
import '../services/revenuecat_service.dart';
import '../repositories/fortune_content_repository.dart';
import '../helpers/constants.dart';

class FortuneViewModel extends ChangeNotifier {
  final FortuneContentRepository _fortuneContentRepository;
  final UserService _userService;
  final HapticService _hapticService;
  final RevenueCatService _purchaseService;
  final FortuneTeller _fortuneTeller;

  bool _isInitialized = false;
  bool isHome = true;
  bool isFortuneInProgress = false;
  bool isFortuneCompleted = false;
  bool isKeyboardVisible = false;
  String welcomeMessage = '';
  List<String> randomQuestions = [];
  late TypeWriterController fortuneController;
  Map<String, String> cachedPrices = {};

  FortuneViewModel(
    this._fortuneContentRepository,
    this._userService,
    this._hapticService,
    this._purchaseService,
    this._fortuneTeller,
  ) {
    fortuneController = TypeWriterController.fromStream(const Stream.empty());
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    debugPrint('FortuneViewModel: Starting initialization');
    try {
      await Future.wait([
        _initializeFortuneTeller(),
        _fetchRandomQuestions(),
      ]);
      welcomeMessage = _getRandomWelcomeMessage();
      _isInitialized = true;
      notifyListeners();
      debugPrint('FortuneViewModel: Initialization complete');
    } catch (e, stackTrace) {
      debugPrint('FortuneViewModel: Error during initialization: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _initializeFortuneTeller() async {
    debugPrint('FortuneViewModel: Starting _initializeFortuneTeller');
    final personaData = await _fortuneContentRepository.getRandomPersona();
    debugPrint('FortuneViewModel: Got random persona');
    _fortuneTeller.setPersona(
        personaData['name']!, personaData['instructions']!);
    debugPrint('FortuneViewModel: _initializeFortuneTeller complete');
  }

  Future<void> _fetchRandomQuestions() async {
    debugPrint('FortuneViewModel: Starting _fetchRandomQuestions');
    randomQuestions = await _fortuneContentRepository.fetchRandomQuestions();
    debugPrint('FortuneViewModel: _fetchRandomQuestions complete');
  }

  String _getRandomWelcomeMessage() {
    return HomeScreenTexts.greetings[DateTime.now().millisecondsSinceEpoch %
        HomeScreenTexts.greetings.length];
  }

  Future<void> getFortune(String question) async {
    if (getRemainingQuestionsCount() <= 0) {
      _hapticService.warning();
      return;
    }

    if (question.trim().isEmpty) {
      _hapticService.error();
      return;
    }

    _hapticService.success();
    isFortuneInProgress = true;
    isFortuneCompleted = false;
    notifyListeners();

    try {
      await _initializeFortuneTeller();
      final fortuneStream = _fortuneTeller.getFortune(question);
      fortuneController = TypeWriterController.fromStream(fortuneStream);

      // Wait for the fortune to complete
      await for (final _ in fortuneStream) {}

      isFortuneCompleted = true;
    } catch (e) {
      fortuneController = TypeWriterController.fromStream(
          Stream.value('Our puppy is not in the mood...'));
    } finally {
      isFortuneInProgress = false;
      notifyListeners();
    }
  }

  void resetFortuneState() {
    isFortuneCompleted = false;
    isFortuneInProgress = false;
    fortuneController = TypeWriterController.fromStream(const Stream.empty());
    _fetchRandomQuestions();
    notifyListeners();
  }

  int getRemainingQuestionsCount() => _userService.getRemainingQuestionsCount();

  bool hasRunOutOfQuestions() => _userService.hasRunOutOfQuestions();

  Future<void> fetchPricesIfNeeded() async {
    if (hasRunOutOfQuestions() && cachedPrices.isEmpty) {
      try {
        await _purchaseService.ensureInitialized();
        cachedPrices = await _purchaseService.fetchPrices();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading prices: $e');
      }
    }
  }

  Future<bool> handlePurchase(int questionCount) async {
    try {
      await _purchaseService.ensureInitialized();

      if (!await _purchaseService.purchaseProduct(questionCount)) {
        return false;
      }

      await _userService.updatePurchaseHistory(questionCount);
      cachedPrices.clear();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  void setKeyboardVisibility(bool isVisible) {
    isKeyboardVisible = isVisible;
    notifyListeners();
  }

  void leaveHome() {
    isHome = false;
    notifyListeners();
  }
}
