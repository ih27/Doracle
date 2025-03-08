import 'package:flutter/material.dart';
import '../config/dependency_injection.dart';
import '../services/revenuecat_service.dart';
import '../services/unified_analytics_service.dart';
import '../widgets/go_deeper_overlay.dart';
import '../widgets/subscribe_success_popup.dart';
import 'purchase_utils.dart';
import 'show_snackbar.dart';

class IAPUtils {
  static final RevenueCatService _purchaseService = getIt<RevenueCatService>();

  static Future<Map<String, String>> fetchSubscriptionPrices(
      Map<String, String> cachedPrices) async {
    if (cachedPrices.isEmpty) {
      try {
        await _purchaseService.ensureInitialized();
        return await _purchaseService.fetchSubscriptionPrices();
      } catch (e) {
        debugPrint('Error loading prices: $e');
      }
    }
    return cachedPrices;
  }

  static void showIAPOverlay(BuildContext context,
      Map<String, String> cachedPrices, Function(String) onPurchase) {
    showCustomOverlay<String>(
      context: context,
      heightFactor: 0.55,
      overlayBuilder: (dialogContext, close) => GoDeeperOverlay(
        onClose: close,
        onPurchase: (String subscriptionType) {
          close();
          onPurchase(subscriptionType);
        },
        prices: cachedPrices,
      ),
    );
  }

  static Future<bool> handlePurchase(
      BuildContext context, String subscriptionType) async {
    bool success = await purchase(subscriptionType);

    if (context.mounted) {
      if (success) {
        showDialog(
          context: context,
          builder: (BuildContext buildContext) {
            return SubscribeSuccessPopup(
              subscriptionType: subscriptionType,
              onContinue: () {
                Navigator.of(buildContext).pop();
              },
            );
          },
        );
      } else {
        showErrorSnackBar(context, 'Purchase failed. Please try again.');
      }
    }

    return success;
  }

  static Future<bool> purchase(String subscriptionType) async {
    try {
      await _purchaseService.ensureInitialized();
      if (!await _purchaseService.buySubscription(subscriptionType)) {
        return false;
      }

      // Get the price from the RevenueCat service
      final priceMap = await _purchaseService.fetchSubscriptionPrices();
      final priceString = priceMap[subscriptionType];

      // Log subscription with unified analytics
      final analytics = getIt<UnifiedAnalyticsService>();
      analytics.logSubscriptionWithPriceString(
        subscriptionId: subscriptionType,
        priceString: priceString,
      );

      return true;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }
}
