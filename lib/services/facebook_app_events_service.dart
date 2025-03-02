import 'package:facebook_app_events/facebook_app_events.dart';

class FacebookAppEventsService {
  static FacebookAppEventsService? _instance;
  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();
  bool _isInitialized = false;

  FacebookAppEventsService._() {
    _initialize();
  }

  factory FacebookAppEventsService() {
    return _instance ??= FacebookAppEventsService._();
  }

  Future<void> _initialize() async {
    if (!_isInitialized) {
      await _facebookAppEvents.setAutoLogAppEventsEnabled(true);
      await _facebookAppEvents.setAdvertiserTracking(enabled: true);
      _isInitialized = true;
    }
  }

  // Basic events
  Future<void> logActivateApp() async {
    await _initialize();
    await _facebookAppEvents.logEvent(
      name: 'fb_mobile_activate_app',
    );
  }

  // Registration event - used in app_manager.dart
  Future<void> logCompleteRegistration({String? registrationMethod}) async {
    await _initialize();
    await _facebookAppEvents.logCompletedRegistration(
      registrationMethod: registrationMethod,
    );
  }

  // Content view event - used in fortune_view_model.dart
  Future<void> logViewContent({
    required String contentType,
    required String contentId,
    Map<String, dynamic>? parameters,
  }) async {
    await _initialize();
    final Map<String, dynamic> params = {
      'content_type': contentType,
      'content_id': contentId,
    };

    if (parameters != null) {
      params.addAll(parameters);
    }

    await _facebookAppEvents.logEvent(
      name: 'fb_mobile_content_view',
      parameters: params,
    );
  }

  // Custom event - used in settings_screen.dart, map_overlay.dart, app_manager.dart
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    await _initialize();
    await _facebookAppEvents.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  // User data
  Future<void> setUserData({
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? city,
    String? state,
    String? zip,
    String? country,
  }) async {
    await _initialize();
    await _facebookAppEvents.setUserData(
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      dateOfBirth: dateOfBirth,
      gender: gender,
      city: city,
      state: state,
      zip: zip,
      country: country,
    );
  }

  // Purchase events
  Future<void> logPurchase({
    required double price,
    required String currency,
    String? productId,
    Map<String, dynamic>? parameters,
  }) async {
    await _initialize();
    final Map<String, dynamic> params = {
      'product_id': productId ?? '',
      'price': price,
    };

    if (parameters != null) {
      params.addAll(parameters);
    }

    await _facebookAppEvents.logPurchase(
      amount: price,
      currency: currency,
      parameters: params,
    );
  }

  // Simple purchase method - used in fortune_view_model.dart
  Future<void> logPurchaseWithPriceString({
    String? priceString,
    String? productIdentifier,
    Map<String, dynamic>? parameters,
  }) async {
    await _initialize();

    final Map<String, dynamic> params = {
      'product_id': productIdentifier ?? '',
    };

    if (priceString != null) {
      params['price_string'] = priceString;
    }

    if (parameters != null) {
      params.addAll(parameters);
    }

    await _facebookAppEvents.logEvent(
      name: 'Purchase',
      parameters: params,
    );
  }

  // Subscription events - keep base method for completeness
  Future<void> logSubscribe({
    required String subscriptionId,
    double? price,
    String? currency,
    Map<String, dynamic>? parameters,
  }) async {
    await _initialize();
    final Map<String, dynamic> params = {
      'subscription_id': subscriptionId,
    };

    if (price != null) {
      params['price'] = price;
    }

    if (parameters != null) {
      params.addAll(parameters);
    }

    if (price != null && currency != null) {
      await _facebookAppEvents.logPurchase(
        amount: price,
        currency: currency,
        parameters: params,
      );
    }

    await _facebookAppEvents.logEvent(
      name: 'Subscribe',
      parameters: params,
    );
  }

  // Simple subscription method - used in iap_utils.dart
  Future<void> logSubscribeWithPriceString({
    required String subscriptionId,
    String? priceString,
    Map<String, dynamic>? parameters,
  }) async {
    await _initialize();

    final Map<String, dynamic> params = {
      'subscription_id': subscriptionId,
    };

    if (priceString != null) {
      params['price_string'] = priceString;
    }

    if (parameters != null) {
      params.addAll(parameters);
    }

    await _facebookAppEvents.logEvent(
      name: 'Subscribe',
      parameters: params,
    );
  }

  // Privacy methods
  Future<void> clearUserData() async {
    await _initialize();
    await _facebookAppEvents.clearUserData();
  }

  Future<void> flushEvents() async {
    await _initialize();
    await _facebookAppEvents.flush();
  }
}
