import 'package:flutter/foundation.dart';
import 'dart:async';
import '../helpers/constants.dart';
import '../providers/entitlement_provider.dart';
import '../services/fortune_teller_service.dart';
import '../services/unified_analytics_service.dart';
import '../services/user_service.dart';
import '../services/haptic_service.dart';
import '../services/revenuecat_service.dart';
import '../services/connectivity_service.dart';
import '../repositories/fortune_content_repository.dart';
import '../config/dependency_injection.dart';

class FortuneViewModel extends ChangeNotifier {
  final FortuneContentRepository _fortuneContentRepository;
  final UserService _userService;
  final HapticService _hapticService;
  final RevenueCatService _purchaseService;
  final EntitlementProvider _entitlementProvider;
  bool get isSubscribed => _entitlementProvider.isEntitled;
  final FortuneTeller _fortuneTeller;
  final ConnectivityService _connectivityService = getIt<ConnectivityService>();
  final UnifiedAnalyticsService _unifiedAnalyticsService =
      getIt<UnifiedAnalyticsService>();

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

    _unifiedAnalyticsService.logEvent(
      name: 'fortune_reading',
      parameters: {
        'question': question,
      },
    );

    // Create a controller to transform the stream
    final controller = StreamController<String>();

    // Check connectivity before making the API request
    _connectivityService.isConnected().then((isConnected) {
      if (!isConnected) {
        // Return an error message if there's no connection
        controller.add(
            '\n\nI can\'t seem to reach my crystal ball. Please check your internet connection and try again.');
        controller.close();
        return;
      }

      // If connected, proceed with the original request
      _fortuneTeller.getFortune(question).listen(
            (data) => controller.add(data),
            onError: (error) {
              controller.add(
                  '\n\nSorry, something went wrong with my crystal ball. Please try again later.');
              controller.close();
            },
            onDone: () => controller.close(),
          );
    });

    return controller.stream;
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
      _unifiedAnalyticsService.logPurchaseWithPriceString(
        priceString: priceString ?? '',
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
