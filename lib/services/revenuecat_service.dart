import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RevenueCatService {
  final String _lastUserIdKey = 'last_revenue_cat_user_id';
  final Map<int, String> _productsHash = {
    10: 'small_treat',
    30: 'medium_treat',
    50: 'large_treat'
  };
  String? _lastInitializedUserId;
  bool _isConfigured = false;
  List<StoreProduct>? _cachedProducts;
  List<String> get _products => _productsHash.values.toList();
  Completer<void>? _initializationCompleter;

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

  void clearProductCache() {
    _cachedProducts = null;
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
      // If not initialized, attempt to initialize with the last known user ID
      String? userId = await _getLastLoggedInUserId();
      if (userId == null) {
        throw StateError(
            'RevenueCatService cannot auto-initialize without a user ID. Call initializeAndLogin first.');
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

    if (lastUserId != userId) {
      final loginResult = await Purchases.logIn(userId);
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
}
