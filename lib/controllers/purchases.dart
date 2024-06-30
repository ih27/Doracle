import 'dart:io';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PurchasesController {
  static Future<void> initialize() async {
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
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  static Future<List<Package>> fetchPackages() async {
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

  static Future<bool> purchasePackage(
      BuildContext context, Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkEntitlement(String entitlementId) async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(entitlementId);
    } catch (e) {
      // Log error internally or to a remote logging service
      return false;
    }
  }

  static Future<bool> restorePurchases(BuildContext context) async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
