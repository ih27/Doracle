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
  bool _isConfigured = false;
  List<StoreProduct>? _cachedProducts;
  List<String> get _products => _productsHash.values.toList();

  Future<bool> purchaseProduct(int questionCount) async {
    try {
      final StoreProduct? product =
          await _getProduct(_productsHash[questionCount]!);
      await Purchases.purchaseStoreProduct(product!);
      return true;
    } catch (e) {
      debugPrint("Purchase product error: $e");
      return false;
    }
  }

  Future<Map<String, String>> fetchPrices() async {
    final products = await _getProducts();
    return {for (var p in products) p.identifier: p.priceString};
  }

  void clearProductCache() {
    _cachedProducts = null;
  }

  Future<void> initializeAndLogin(String userId) async {
    try {
      if (!_isConfigured) {
        await _configureSDK(userId);
      } else {
        await _loginIfNeeded(userId);
      }
    } catch (e) {
      debugPrint("Error in initializeAndLogin: $e");
    }
  }

  Future<List<StoreProduct>> _getProducts() async {
    _cachedProducts ??= await Purchases.getProducts(_products);
    return _cachedProducts!;
  }

  Future<StoreProduct?> _getProduct(String identifier) async {
    final products = await Purchases.getProducts([identifier]);
    return products.isNotEmpty ? products.first : null;
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
    debugPrint("RevenueCat SDK configured with user ID: $userId");
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
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUserIdKey);
  }

  Future<void> _setLastLoggedInUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUserIdKey, userId);
  }
}
