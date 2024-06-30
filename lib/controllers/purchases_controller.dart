import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../helpers/show_snackbar.dart';

class PurchasesController {
  static Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);
    final apiKey = dotenv.env['REVENUECAT_API_KEY'];
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
      if (context.mounted) {
        showErrorSnackBar(context, 'Error making purchase: $e');
      }
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
      if (context.mounted) {
        showErrorSnackBar(context, 'Error restoring purchases: $e');
      }
      return false;
    }
  }
}
