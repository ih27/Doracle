import 'dart:io';
import 'package:flutter/material.dart';
import '../dependency_injection.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../services/auth_service.dart';

class PurchasesController {
  bool _isInitialized = false;
  late Map<int, Package> packageHash;

  Future<void> initialize() async {
    if (_isInitialized) {
      return; // SDK is already configured
    }

    await Purchases.setLogLevel(LogLevel.debug);
    late String keyName;

    if (Platform.isAndroid) {
      keyName = 'REVENUECAT_ANDROID_API_KEY';
    } else if (Platform.isIOS) {
      keyName = 'REVENUECAT_IOS_API_KEY';
    }

    final apiKey = dotenv.env[keyName];
    if (apiKey == null) {
      throw Exception('RevenueCat API key not found in .env file');
    }
    await Purchases.configure(PurchasesConfiguration(apiKey)
      ..appUserID = getIt<AuthService>().currentUser?.uid);

    packageHash = await _buildPackageMap();

    _isInitialized = true;
  }

  Future<List<Package>> _fetchPackages() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      // Log error internally or to a remote logging service
    }
    return [];
  }

  Future<bool> purchasePackage(int questionCount) async {
    await _ensureInitialized();
    try {
      await Purchases.purchasePackage(packageHash[questionCount]!);
      return true;
    } catch (e) {
      debugPrint("purchase package error: $e");
      return false;
    }
  }

  Future<bool> checkEntitlement(String entitlementId) async {
    await _ensureInitialized();
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(entitlementId);
    } catch (e) {
      // Log error internally or to a remote logging service
      return false;
    }
  }

  Future<bool> restorePurchases(BuildContext context) async {
    await _ensureInitialized();
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<Map<String, String>> fetchPrices() async {
    Map<String, String> prices = {};
    await _ensureInitialized();
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        for (var package in offerings.current!.availablePackages) {
          prices[package.storeProduct.identifier] =
              package.storeProduct.priceString;
        }
      }
    } catch (e) {
      debugPrint("Fetch prices error: $e");
    }
    return prices;
  }

  Future<Map<int, Package>> _buildPackageMap() async {
    const mapping = {
      10: 'small_treat',
      30: 'medium_treat',
      50: 'large_treat',
    };

    final packages = await _fetchPackages();
    final packageMap = <int, Package>{};

    for (final package in packages) {
      for (final entry in mapping.entries) {
        if (package.storeProduct.identifier == entry.value) {
          packageMap[entry.key] = package;
          break; // Move to the next package once a match is found
        }
      }
    }

    return packageMap;
  }
}
