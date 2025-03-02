import 'package:flutter/foundation.dart';
import '../helpers/constants.dart';
import '../providers/entitlement_provider.dart';
import '../services/facebook_app_events_service.dart';
import '../services/fortune_teller_service.dart';
import '../services/user_service.dart';
import '../services/haptic_service.dart';
import '../services/revenuecat_service.dart';
import '../repositories/fortune_content_repository.dart';
import 'package:get_it/get_it.dart';

class FortuneViewModel extends ChangeNotifier {
  final FortuneContentRepository _fortuneContentRepository;
  final UserService _userService;
  final HapticService _hapticService;
  final RevenueCatService _purchaseService;
  final EntitlementProvider _entitlementProvider;
  bool get isSubscribed => _entitlementProvider.isEntitled;
  final FortuneTeller _fortuneTeller;
  final FacebookAppEventsService _facebookAppEvents =
      GetIt.instance<FacebookAppEventsService>();

  bool isHome = true;
  String welcomeMessage = '';
  List<String> randomQuestions = [];
  Map<String, String> cachedPrices = {};
  int _remainingQuestionsCount = 0;
  int get remainingQuestionsCount => _remainingQuestionsCount;

  FortuneViewModel(
    this._fortuneContentRepository,
    this._userService,
    this._hapticService,
    this._purchaseService,
    this._entitlementProvider,
    this._fortuneTeller,
  ) {
    _entitlementProvider.addListener(_onEntitlementChanged);
    _remainingQuestionsCount = _userService.getRemainingQuestionsCount();
  }

  void _onEntitlementChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _entitlementProvider.removeListener(_onEntitlementChanged);
    super.dispose();
  }

  Future<void> initialize() async {
    await Future.wait([
      _initializeFortuneTeller(),
      _fetchRandomQuestions(),
      _fetchPricesIfNeeded(),
    ]);
    welcomeMessage = _getRandomWelcomeMessage();
    notifyListeners();
  }

  Future<void> _initializeFortuneTeller() async {
    final personaData = await _fortuneContentRepository.getRandomPersona();
    _fortuneTeller.setPersona(
        personaData['name']!, personaData['instructions']!);
  }

  Future<void> _fetchRandomQuestions() async {
    randomQuestions = await _fortuneContentRepository.fetchRandomQuestions();
  }

  String _getRandomWelcomeMessage() {
    return HomeScreenTexts.greetings[DateTime.now().millisecondsSinceEpoch %
        HomeScreenTexts.greetings.length];
  }

  Stream<String> getFortune(String question) {
    if (!canAskQuestion()) {
      _hapticService.warning();
      return Stream.value('');
    }

    if (question.trim().isEmpty) {
      _hapticService.error();
      return Stream.value('');
    }

    _hapticService.success();

    // Track content view event for analytics
    _facebookAppEvents.logViewContent(
      contentType: 'fortune_reading',
      contentId: 'fortune_question',
    );

    return _fortuneTeller.getFortune(question);
  }

  void resetFortuneState() {
    _fetchRandomQuestions();
    notifyListeners();
  }

  int getRemainingQuestionsCount() {
    _remainingQuestionsCount = _userService.getRemainingQuestionsCount();
    return _remainingQuestionsCount;
  }

  bool canAskQuestion() {
    return isSubscribed || getRemainingQuestionsCount() > 0;
  }

  bool _hasRunOutOfQuestions() => _userService.hasRunOutOfQuestions();

  Future<void> _fetchPricesIfNeeded() async {
    if (!isSubscribed && _hasRunOutOfQuestions() && cachedPrices.isEmpty) {
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
      _remainingQuestionsCount = getRemainingQuestionsCount();

      // Get price string from cached prices
      final String? priceString = cachedPrices[questionCount.toString()];

      // Log the purchase event to Facebook with the actual price string
      _facebookAppEvents.logPurchaseWithPriceString(
        priceString: priceString,
        productIdentifier: questionCount.toString(),
        parameters: {
          'question_count': questionCount,
          'product_type': 'questions_pack',
        },
      );

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
