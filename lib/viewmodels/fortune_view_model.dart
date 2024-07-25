import 'package:flutter/foundation.dart';
import '../helpers/constants.dart';
import '../services/fortune_teller_service.dart';
import '../services/user_service.dart';
import '../services/haptic_service.dart';
import '../services/revenuecat_service.dart';
import '../repositories/fortune_content_repository.dart';

class FortuneViewModel extends ChangeNotifier {
  final FortuneContentRepository _fortuneContentRepository;
  final UserService _userService;
  final HapticService _hapticService;
  final RevenueCatService _purchaseService;
  final FortuneTeller _fortuneTeller;

  bool isHome = true;
  String welcomeMessage = '';
  List<String> randomQuestions = [];
  Map<String, String> cachedPrices = {};

  FortuneViewModel(
    this._fortuneContentRepository,
    this._userService,
    this._hapticService,
    this._purchaseService,
    this._fortuneTeller,
  );

  Future<void> initialize() async {
    await Future.wait([
      _initializeFortuneTeller(),
      _fetchRandomQuestions(),
    ]);
    welcomeMessage = _getRandomWelcomeMessage();
    notifyListeners();
  }

  Future<void> _initializeFortuneTeller() async {
    final personaData = await _fortuneContentRepository.getRandomPersona();
    _fortuneTeller.setPersona(personaData['name']!, personaData['instructions']!);
  }

  Future<void> _fetchRandomQuestions() async {
    randomQuestions = await _fortuneContentRepository.fetchRandomQuestions();
  }

  String _getRandomWelcomeMessage() {
    return HomeScreenTexts.greetings[DateTime.now().millisecondsSinceEpoch %
        HomeScreenTexts.greetings.length];
  }

  Stream<String> getFortune(String question) {
    if (getRemainingQuestionsCount() <= 0) {
      _hapticService.warning();
      return Stream.value('');
    }

    if (question.trim().isEmpty) {
      _hapticService.error();
      return Stream.value('');
    }

    _hapticService.success();
    return _fortuneTeller.getFortune(question);
  }

  void resetFortuneState() {
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

  void leaveHome() {
    isHome = false;
    notifyListeners();
  }
}