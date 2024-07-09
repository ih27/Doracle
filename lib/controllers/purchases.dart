import 'dart:io';
import 'package:flutter/material.dart';
import '../dependency_injection.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../services/auth_service.dart';

class PurchasesController {
  bool _isInitialized = false;

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
    await Purchases.configure(
        PurchasesConfiguration(apiKey)..appUserID = getIt<AuthService>().currentUser?.uid);

    _isInitialized = true;
  }

  Future<List<Package>> fetchPackages() async {
    await _ensureInitialized();
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

  Future<bool> purchasePackage(BuildContext context, Package package) async {
    await _ensureInitialized();
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
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
}
