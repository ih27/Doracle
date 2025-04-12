import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/constants.dart';
import 'auth_service.dart';

class RevenueCatService with ChangeNotifier {
  final AuthService _authService;
  final String _lastUserIdKey = 'last_revenue_cat_user_id';
  final String _anonymousUserIdKey = 'anonymous_revenue_cat_user_id';
  final Map<int, String> _productsHash = {
    PurchaseTexts.smallTreatQuestionCount: PurchaseTexts.smallTreatPackageId,
    PurchaseTexts.mediumTreatQuestionCount: PurchaseTexts.mediumTreatPackageId,
    PurchaseTexts.largeTreatQuestionCount: PurchaseTexts.largeTreatPackageId,
  };
  String? _lastInitializedUserId;
  bool _isConfigured = false;
  List<StoreProduct>? _cachedProducts;
  Map<String, Package> _cachedSubscriptions = {};

  List<String> get _products => _productsHash.values.toList();
  Completer<void>? _initializationCompleter;

  bool _isEntitled = false;
  bool get isEntitled => _isEntitled;

  set isEntitled(bool value) {
    if (_isEntitled != value) {
      _isEntitled = value;
      notifyListeners();
    }
  }

  String? _currentSubscriptionPlan;
  String? get currentSubscriptionPlan => _currentSubscriptionPlan;

  RevenueCatService(this._authService);

  Future<bool> getEntitlementStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();
    if (customerInfo.entitlements.active.isNotEmpty) {
      _currentSubscriptionPlan =
          customerInfo.entitlements.active.values.first.productIdentifier;
      notifyListeners();
      return true;
    }
    _currentSubscriptionPlan = null;
    notifyListeners();
    return false;
  }

  Future<bool> purchaseProduct(int questionCount) async {
    try {
      await ensureInitialized();
      final String? productIdentifier = _productsHash[questionCount];
      if (productIdentifier == null) {
        debugPrint("Invalid question count: $questionCount");
        return false;
      }

      final StoreProduct? product = await _getProduct(productIdentifier);
      if (product == null) {
        debugPrint("Product not found for identifier: $productIdentifier");
        return false;
      }

      await Purchases.purchaseStoreProduct(product);
      return true;
    } catch (e) {
      debugPrint("Purchase product error: $e");
      return false;
    }
  }

  Future<bool> buySubscription(String subscriptionType) async {
    debugPrint('Trying to purchase: $subscriptionType');
    try {
      await ensureInitialized();
      CustomerInfo customerInfo = await Purchases.purchasePackage(
          _cachedSubscriptions[subscriptionType]!);
      if (customerInfo.entitlements.active.isNotEmpty) {
        _currentSubscriptionPlan =
            customerInfo.entitlements.active.values.first.productIdentifier;
        isEntitled = true;
      } else {
        _currentSubscriptionPlan = null;
        isEntitled = false;
      }
      notifyListeners();
      return _isEntitled;
    } catch (e) {
      debugPrint("Buy subscription error: $e");
      return _isEntitled;
    }
  }

  Future<bool> restorePurchase() async {
    debugPrint('Trying to restore purchase...');
    try {
      await ensureInitialized();
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      if (customerInfo.entitlements.active.isNotEmpty) {
        isEntitled = true;
      } else {
        isEntitled = false;
      }
      return _isEntitled;
    } catch (e) {
      debugPrint("Restore subscription error: $e");
      return _isEntitled;
    }
  }

  Future<Map<String, String>> fetchPrices() async {
    try {
      await ensureInitialized();
      final products = await _getProducts();
      return {for (var p in products) p.identifier: p.priceString};
    } catch (e) {
      debugPrint("Error fetching prices: $e");
      return {};
    }
  }

  Future<Map<String, String>> fetchSubscriptionPrices() async {
    try {
      await ensureInitialized();
      final subscriptions = await _getSubscriptions();
      return {
        for (var p in subscriptions.values)
          p.identifier: p.storeProduct.priceString
      };
    } catch (e) {
      debugPrint("Error fetching subscription prices: $e");
      return {};
    }
  }

  void clearProductCache() {
    _cachedProducts = null;
    _cachedSubscriptions = {};
  }

  Future<void> initializeAndLogin(String userId) async {
    // If already initializing or initialized for this user, just wait for completion
    if (_initializationCompleter != null && _lastInitializedUserId == userId) {
      return _initializationCompleter!.future;
    }

    // If initializing for a different user, reset the completer
    if (_lastInitializedUserId != userId) {
      _initializationCompleter = null;
    }

    _initializationCompleter = Completer<void>();
    _lastInitializedUserId = userId;

    try {
      if (!_isConfigured) {
        await _configureSDK(userId);
      } else {
        await _loginIfNeeded(userId);
      }

      // Update the entitlement status after initialization
      isEntitled = await getEntitlementStatus();

      _initializationCompleter!.complete();
    } catch (e) {
      debugPrint("Error in initializeAndLogin: $e");
      _initializationCompleter!.completeError(e);
      // Reset the completer and last user ID on error
      _initializationCompleter = null;
      _lastInitializedUserId = null;
    }

    return _initializationCompleter!.future;
  }

  Future<void> ensureInitialized() async {
    if (_initializationCompleter == null) {
      String? userId = await _getLastLoggedInUserId();
      if (userId == null) {
        final currentUser = _authService.currentUser;
        if (currentUser != null) {
          userId = currentUser.uid;
          await _setLastLoggedInUserId(userId);
        } else {
          userId = await _getOrCreateAnonymousUserId();
        }
      }
      return initializeAndLogin(userId);
    }
    return _initializationCompleter!.future;
  }

  Future<List<StoreProduct>> _getProducts() async {
    try {
      _cachedProducts ??= await Purchases.getProducts(_products);
      return _cachedProducts!;
    } catch (e) {
      debugPrint("Error getting products: $e");
      return [];
    }
  }

  Future<Map<String, Package>> _getSubscriptions() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        if (offerings.current?.weekly != null) {
          _cachedSubscriptions[PurchaseTexts.weekly] =
              offerings.current!.weekly!;
        }
        if (offerings.current?.monthly != null) {
          _cachedSubscriptions[PurchaseTexts.monthly] =
              offerings.current!.monthly!;
        }
        if (offerings.current?.annual != null) {
          _cachedSubscriptions[PurchaseTexts.annual] =
              offerings.current!.annual!;
        }
      }
      return _cachedSubscriptions;
    } catch (e) {
      debugPrint("Error getting subscriptions: $e");
      return {};
    }
  }

  Future<StoreProduct?> _getProduct(String identifier) async {
    try {
      final products = await Purchases.getProducts([identifier]);
      return products.isNotEmpty ? products.first : null;
    } catch (e) {
      debugPrint("Error getting product: $e");
      return null;
    }
  }

  Future<void> _configureSDK(String userId) async {
    await Purchases.setLogLevel(LogLevel.debug);

    final String keyName = Platform.isAndroid
        ? 'REVENUECAT_ANDROID_API_KEY'
        : 'REVENUECAT_IOS_API_KEY';
    final apiKey = dotenv.env[keyName];
    if (apiKey == null) {
      throw Exception('RevenueCat API key not found');
    }

    await Purchases.configure(
        PurchasesConfiguration(apiKey)..appUserID = userId);
    _isConfigured = true;
    await _setLastLoggedInUserId(userId);
  }

  Future<void> _loginIfNeeded(String userId) async {
    final lastUserId = await _getLastLoggedInUserId();
    final anonymousId = await _getOrCreateAnonymousUserId();

    if (lastUserId != userId) {
      LogInResult loginResult;

      // If coming from anonymous user and moving to real user
      if (lastUserId == anonymousId && !userId.startsWith('anon_')) {
        loginResult = await Purchases.logIn(userId);
        await _clearAnonymousUser();
        debugPrint(
            "Transferred purchases from anonymous to authenticated user");
      } else {
        loginResult = await Purchases.logIn(userId);
      }

      await _setLastLoggedInUserId(userId);
      debugPrint(
          "RevenueCat login successful for ${loginResult.customerInfo.originalAppUserId}");
    } else {
      debugPrint("User $userId already logged in to RevenueCat.");
    }
  }

  Future<String?> _getLastLoggedInUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastUserIdKey);
    } catch (e) {
      debugPrint("Error getting last logged in user ID: $e");
      return null;
    }
  }

  Future<void> _setLastLoggedInUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUserIdKey, userId);
    } catch (e) {
      debugPrint("Error setting last logged in user ID: $e");
    }
  }

  Future<String> _getOrCreateAnonymousUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? anonymousId = prefs.getString(_anonymousUserIdKey);
    if (anonymousId == null) {
      // Create a new anonymous ID with 'anon_' prefix and timestamp
      anonymousId = 'anon_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_anonymousUserIdKey, anonymousId);
    }
    return anonymousId;
  }

  Future<void> _clearAnonymousUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_anonymousUserIdKey);
  }
}
