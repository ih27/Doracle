import 'dart:io' show Platform;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:permission_handler/permission_handler.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  bool _isCollectionEnabled = true;
  // Get the Firebase Analytics instance (in case you need direct access)
  FirebaseAnalytics get instance => _analytics;

  // Initialize analytics and enable/disable collection
  Future<void> _init({bool limitedTracking = false}) async {
    _isCollectionEnabled = !limitedTracking;
    await _analytics.setAnalyticsCollectionEnabled(_isCollectionEnabled);
  }

  Future<void> initialize() async {
    if (Platform.isIOS) {
      // Check the current status instead of requesting again
      final status = await Permission.appTrackingTransparency.status;

      if (status.isGranted) {
        await _init();
      } else {
        // User denied permission or hasn't been prompted, initialize with limited tracking
        await _init(limitedTracking: true);
      }
    } else {
      // For non-iOS platforms, initialize normally
      await _init();
    }
  }

  // Log a custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_isCollectionEnabled) return;
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // Set a user property
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!_isCollectionEnabled) return;
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Log when a screen is viewed
  Future<void> logScreenView({required String screenName}) async {
    if (!_isCollectionEnabled) return;
    await _analytics.logScreenView(
      screenName: screenName,
    );
  }

  // Log when a user signs up
  Future<void> logSignUp({required String signUpMethod}) async {
    if (!_isCollectionEnabled) return;
    await _analytics.logSignUp(signUpMethod: signUpMethod);
  }

  // Log when a user logs in
  Future<void> logLogin({String? loginMethod}) async {
    if (!_isCollectionEnabled) return;
    await _analytics.logLogin(loginMethod: loginMethod);
  }

  // Log when a user starts a purchase
  Future<void> logBeginCheckout({
    double? value,
    String? currency,
    List<AnalyticsEventItem>? items,
  }) async {
    if (!_isCollectionEnabled) return;
    await _analytics.logBeginCheckout(
      value: value,
      currency: currency,
      items: items,
    );
  }

  // Log when a purchase is completed
  Future<void> logPurchase({
    double? value,
    String? currency,
    List<AnalyticsEventItem>? items,
  }) async {
    if (!_isCollectionEnabled) return;
    await _analytics.logPurchase(
      value: value,
      currency: currency,
      items: items,
    );
  }
}

// example usage

// // Log a custom event
// analytics.logEvent(name: 'button_click', parameters: {'button_id': 'submit_form'});

// // Set a user property
// analytics.setUserProperty(name: 'user_type', value: 'premium');

// // Log a screen view
// analytics.logScreenView(screenName: 'Home Screen');

// // Log a purchase
// analytics.logPurchase(
//   value: 9.99,
//   currency: 'USD',
//   items: [AnalyticsEventItem(itemName: 'Premium Subscription', price: 9.99)],
// );
