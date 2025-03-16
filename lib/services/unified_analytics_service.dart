import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

import 'analytics_service.dart';
import 'facebook_app_events_service.dart';
import 'adjust_service.dart';
import '../config/adjust_config.dart';

/// UnifiedAnalyticsService
///
/// A unified interface for analytics that sends events to all configured
/// analytics services (Firebase, Facebook, Adjust) with a single call.
///
/// All analytics calls are non-blocking (fire-and-forget) to ensure they
/// don't impact app performance or user experience.
class UnifiedAnalyticsService {
  final AnalyticsService _firebaseAnalytics;
  final FacebookAppEventsService _facebookEvents;
  final AdjustService _adjustService;
  // Track whether ATT permission has been granted
  bool _isTrackingAllowed = false;

  UnifiedAnalyticsService(
    this._firebaseAnalytics,
    this._facebookEvents,
    this._adjustService,
  );

  /// Initialize all analytics services at once
  /// This is awaited since it's critical for proper setup
  Future<void> initialize() async {
    if (Platform.isIOS) {
      // Check current ATT permission status
      final attStatus = await Permission.appTrackingTransparency.status;
      _isTrackingAllowed = attStatus.isGranted;
      debugPrint(
          'Unified Analytics initializing with ATT status: ${attStatus.toString()}');
    } else {
      // For non-iOS platforms, assume tracking is allowed
      _isTrackingAllowed = true;
    }

    // Initialize all services with the current permission status
    await _firebaseAnalytics.initialize();
    await _adjustService.initialize();

    // Only activate app tracking if permission was granted
    if (_isTrackingAllowed || !Platform.isIOS) {
      await _facebookEvents.logActivateApp();
    }

    debugPrint(
        'Unified Analytics Service initialized (tracking allowed: $_isTrackingAllowed)');
  }

  /// Log a custom event across all platforms in a non-blocking way
  void logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    try {
      // Firebase Analytics - fire and forget
      unawaited(_firebaseAnalytics.logEvent(
        name: name,
        parameters: parameters,
      ));

      // Facebook App Events - fire and forget
      unawaited(_facebookEvents.logCustomEvent(
        eventName: name,
        parameters: parameters?.cast<String, dynamic>(),
      ));

      // Automatically determine if we should track in Adjust based on event name
      String? adjustEventToken;

      // Map common events to Adjust tokens
      if (name == 'tutorial_complete') {
        adjustEventToken = AdjustEvents.tutorialComplete;
      } else if (name == 'rate_app') {
        adjustEventToken = AdjustEvents.rateApp;
      } else if (name == 'location_search') {
        adjustEventToken = AdjustEvents.locationSearch;
      }

      // If we have a token for this event, track it in Adjust
      if (adjustEventToken != null) {
        final Map<String, String> adjustParams = {};
        if (parameters != null) {
          // Convert parameters to string values for Adjust
          parameters.forEach((key, value) {
            adjustParams[key] = value.toString();
          });
        }
        unawaited(_adjustService.trackEvent(adjustEventToken,
            callbackParameters: adjustParams));
      }

      debugPrint('Event logged to all services: $name');
    } catch (e) {
      debugPrint('Error logging event to analytics services: $e');
    }
  }

  /// Log screen view across platforms in a non-blocking way
  void logScreenView({required String screenName}) {
    try {
      // Firebase Analytics - fire and forget
      unawaited(_firebaseAnalytics.logScreenView(screenName: screenName));

      // Facebook App Events - fire and forget
      unawaited(_facebookEvents.logViewContent(
        contentType: 'screen',
        contentId: screenName,
      ));

      debugPrint('Screen view logged to all services: $screenName');
    } catch (e) {
      debugPrint('Error logging screen view: $e');
    }
  }

  /// Log user sign up across platforms in a non-blocking way
  void logSignUp({
    required String signUpMethod,
  }) {
    try {
      // Firebase Analytics - fire and forget
      unawaited(_firebaseAnalytics.logSignUp(signUpMethod: signUpMethod));

      // Facebook App Events - fire and forget
      unawaited(_facebookEvents.logCompleteRegistration(
        registrationMethod: signUpMethod,
      ));

      // Use AdjustEvents.registration constant directly
      const String adjustEventToken = AdjustEvents.registration;
      unawaited(
          _adjustService.trackEvent(adjustEventToken, callbackParameters: {
        'method': signUpMethod,
      }));

      debugPrint('Sign up logged to all services: $signUpMethod');
    } catch (e) {
      debugPrint('Error logging sign up: $e');
    }
  }

  /// Log user login across platforms in a non-blocking way
  void logLogin({
    required String loginMethod,
  }) {
    try {
      // Firebase Analytics - fire and forget
      unawaited(_firebaseAnalytics.logLogin(loginMethod: loginMethod));

      // Facebook custom event for login - fire and forget
      unawaited(_facebookEvents.logCustomEvent(
        eventName: 'Login',
        parameters: {'method': loginMethod},
      ));

      // Use AdjustEvents.login constant directly - fire and forget
      const String adjustEventToken = AdjustEvents.login;
      unawaited(
          _adjustService.trackEvent(adjustEventToken, callbackParameters: {
        'method': loginMethod,
      }));

      debugPrint('Login logged to all services: $loginMethod');
    } catch (e) {
      debugPrint('Error logging login: $e');
    }
  }

  /// Log purchase across platforms in a non-blocking way
  void logPurchase({
    required double price,
    required String currency,
    String? productId,
    Map<String, dynamic>? parameters,
  }) {
    try {
      // Prepare parameters
      final Map<String, Object> params = {
        'product_id': productId ?? '',
        'price': price,
        'currency': currency,
      };

      if (parameters != null) {
        params.addAll(
            parameters.map((key, value) => MapEntry(key, value as Object)));
      }

      // Convert to AnalyticsEventItem for Firebase
      final List<AnalyticsEventItem>? items = productId != null
          ? [
              AnalyticsEventItem(
                itemId: productId,
                price: price,
              )
            ]
          : null;

      // Firebase Analytics - fire and forget
      unawaited(_firebaseAnalytics.logPurchase(
        value: price,
        currency: currency,
        items: items,
      ));

      // Facebook App Events - fire and forget
      unawaited(_facebookEvents.logPurchase(
        price: price,
        currency: currency,
        productId: productId,
        parameters: parameters,
      ));

      // Use AdjustEvents.purchase constant directly for revenue tracking - fire and forget
      const String adjustRevenueEventToken = AdjustEvents.purchase;
      final Map<String, String> adjustParams = {};
      if (parameters != null) {
        parameters.forEach((key, value) {
          adjustParams[key] = value.toString();
        });
      }
      unawaited(_adjustService.trackRevenue(
        adjustRevenueEventToken,
        price,
        currency,
        callbackParameters: adjustParams,
      ));

      debugPrint(
          'Purchase logged to all services: $productId, $price $currency');
    } catch (e) {
      debugPrint('Error logging purchase: $e');
    }
  }

  /// Log purchase with price string in a non-blocking way
  void logPurchaseWithPriceString({
    required String priceString,
    String? productIdentifier,
    Map<String, dynamic>? parameters,
  }) {
    try {
      // Extract price as double for services that require numeric values
      double? price;
      if (priceString.isNotEmpty) {
        // Simple extraction of numeric value from price string
        price =
            double.tryParse(priceString.replaceAll(RegExp(r'[^0-9\.]'), ''));
      }

      // Firebase Analytics (custom event for purchase with price string) - fire and forget
      final Map<String, Object> params = {
        'price_string': priceString,
      };

      if (productIdentifier != null) {
        params['product_id'] = productIdentifier;
      }

      if (parameters != null) {
        params.addAll(
            parameters.map((key, value) => MapEntry(key, value as Object)));
      }

      unawaited(_firebaseAnalytics.logEvent(
        name: 'purchase',
        parameters: params,
      ));

      // Facebook App Events - pass the price string directly - fire and forget
      unawaited(_facebookEvents.logPurchaseWithPriceString(
        priceString: priceString,
        productIdentifier: productIdentifier,
        parameters: parameters,
      ));

      // Use the AdjustEvents.purchase token directly
      const String adjustEventToken = AdjustEvents.purchase;

      // Adjust tracking if price is parseable - fire and forget
      if (price != null) {
        final Map<String, String> adjustParams = {
          'price_string': priceString,
        };

        if (productIdentifier != null) {
          adjustParams['product_id'] = productIdentifier;
        }

        if (parameters != null) {
          parameters.forEach((key, value) {
            adjustParams[key] = value.toString();
          });
        }

        // Use default currency USD for Adjust - the actual currency is reflected in priceString
        unawaited(_adjustService.trackRevenue(
          adjustEventToken,
          price,
          'USD', // Use default currency
          callbackParameters: adjustParams,
        ));
      } else {
        // Just track event without revenue if we couldn't parse the price - fire and forget
        final Map<String, String> adjustParams = {
          'price_string': priceString,
        };

        if (productIdentifier != null) {
          adjustParams['product_id'] = productIdentifier;
        }

        if (parameters != null) {
          parameters.forEach((key, value) {
            adjustParams[key] = value.toString();
          });
        }

        unawaited(_adjustService.trackEvent(
          adjustEventToken,
          callbackParameters: adjustParams,
        ));
      }

      debugPrint(
          'Purchase with price string logged: $productIdentifier, $priceString');
    } catch (e) {
      debugPrint('Error logging purchase with price string: $e');
    }
  }

  /// Log subscription across platforms in a non-blocking way
  void logSubscription({
    required String subscriptionId,
    required double price,
    required String currency,
    Map<String, dynamic>? parameters,
  }) {
    try {
      // Prepare parameters
      final Map<String, Object> params = {
        'subscription_id': subscriptionId,
        'price': price,
        'currency': currency,
      };

      if (parameters != null) {
        params.addAll(
            parameters.map((key, value) => MapEntry(key, value as Object)));
      }

      // Firebase Analytics (custom event for subscription) - fire and forget
      unawaited(_firebaseAnalytics.logEvent(
        name: 'subscription_purchase',
        parameters: params,
      ));

      // Facebook App Events - fire and forget
      unawaited(_facebookEvents.logSubscribe(
        subscriptionId: subscriptionId,
        price: price,
        currency: currency,
        parameters: parameters,
      ));

      // Use AdjustEvents.subscription constant directly - fire and forget
      const String adjustRevenueEventToken = AdjustEvents.subscription;
      final Map<String, String> adjustParams = {
        'subscription_id': subscriptionId,
      };
      if (parameters != null) {
        parameters.forEach((key, value) {
          adjustParams[key] = value.toString();
        });
      }
      unawaited(_adjustService.trackRevenue(
        adjustRevenueEventToken,
        price,
        currency,
        callbackParameters: adjustParams,
      ));

      debugPrint(
          'Subscription logged to all services: $subscriptionId, $price $currency');
    } catch (e) {
      debugPrint('Error logging subscription: $e');
    }
  }

  /// Log subscription with price string in a non-blocking way
  void logSubscriptionWithPriceString({
    required String subscriptionId,
    String? priceString,
    Map<String, dynamic>? parameters,
  }) {
    try {
      // Prepare parameters
      final Map<String, Object> params = {
        'subscription_id': subscriptionId,
      };

      if (priceString != null) {
        params['price_string'] = priceString;
      }

      if (parameters != null) {
        params.addAll(
            parameters.map((key, value) => MapEntry(key, value as Object)));
      }

      // Firebase Analytics (custom event) - fire and forget
      unawaited(_firebaseAnalytics.logEvent(
        name: 'subscription_purchase',
        parameters: params,
      ));

      // Facebook App Events - fire and forget
      unawaited(_facebookEvents.logSubscribeWithPriceString(
        subscriptionId: subscriptionId,
        priceString: priceString,
        parameters: parameters,
      ));

      // Use the AdjustEvents.subscription token directly - fire and forget
      const String adjustEventToken = AdjustEvents.subscription;

      // Adjust Event
      final Map<String, String> adjustParams = {
        'subscription_id': subscriptionId,
      };
      if (priceString != null) {
        adjustParams['price_string'] = priceString;
      }
      if (parameters != null) {
        parameters.forEach((key, value) {
          adjustParams[key] = value.toString();
        });
      }
      unawaited(_adjustService.trackEvent(
        adjustEventToken,
        callbackParameters: adjustParams,
      ));

      debugPrint(
          'Subscription with price string logged: $subscriptionId, $priceString');
    } catch (e) {
      debugPrint('Error logging subscription with price string: $e');
    }
  }

  /// Set user property in a non-blocking way
  void setUserProperty({
    required String name,
    required String? value,
  }) {
    try {
      // Firebase Analytics - fire and forget
      unawaited(_firebaseAnalytics.setUserProperty(name: name, value: value));
      debugPrint('User property set: $name = $value');
    } catch (e) {
      debugPrint('Error setting user property: $e');
    }
  }

  /// Helper to make unawaited calls more explicit
  static void unawaited(Future<void> future) {
    // Intentionally not awaiting the future
    future.catchError((error) {
      debugPrint('Caught error in unawaited analytics call: $error');
      // Errors are only logged, not propagated
      return null;
    });
  }
}
