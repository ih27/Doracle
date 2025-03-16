import 'package:facebook_app_events/facebook_app_events.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class FacebookAppEventsService {
  static FacebookAppEventsService? _instance;
  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();
  bool _isInitialized = false;

  // Constants
  static const String _skadNetworkSchema = 'SKAdNetwork';

  // Conversion values for different actions
  static const int _registrationConversionValue = 2;
  static const int _purchaseConversionValue = 4;
  static const int _subscriptionConversionValue = 6;

  FacebookAppEventsService._() {
    _initialize();
  }

  factory FacebookAppEventsService() {
    return _instance ??= FacebookAppEventsService._();
  }

  Future<void> _initialize() async {
    if (!_isInitialized) {
      // Always enable auto logging
      await _facebookAppEvents.setAutoLogAppEventsEnabled(true);

      if (Platform.isIOS) {
        try {
          // Check ATT permission status before enabling advertiser tracking
          final attStatus = await Permission.appTrackingTransparency.status;
          debugPrint(
              'Facebook Events initializing with ATT status: ${attStatus.toString()}');

          // Only enable advertiser tracking if permission is granted
          await _facebookAppEvents.setAdvertiserTracking(
              enabled: attStatus.isGranted);

          debugPrint(
              'Initializing Facebook App Events with SKAdNetwork support');
        } catch (e) {
          debugPrint('Error initializing Facebook App Events for iOS 14+: $e');
          // Default to disabled tracking on error
          await _facebookAppEvents.setAdvertiserTracking(enabled: false);
        }
      } else {
        // For non-iOS platforms, enable tracking by default
        await _facebookAppEvents.setAdvertiserTracking(enabled: true);
      }

      _isInitialized = true;
    }
  }

  /// Core method to log events with platform-specific handling
  Future<void> _logEventCore({
    required String name,
    Map<String, dynamic>? parameters,
    int? conversionValue,
  }) async {
    await _initialize();

    // Handle parameters
    final Map<String, dynamic> params = parameters ?? {};

    if (Platform.isIOS) {
      // For iOS, include SKAdNetwork schema in parameters
      params['schema'] = _skadNetworkSchema;

      // Update conversion value if provided
      if (conversionValue != null) {
        await updateConversionValue(conversionValue);
      }
    }

    // Log the event with the appropriate parameters
    await _facebookAppEvents.logEvent(
      name: name,
      parameters: params.isNotEmpty ? params : null,
    );
  }

  // Basic events
  Future<void> logActivateApp() async {
    await _logEventCore(
      name: 'fb_mobile_activate_app',
    );
  }

  // Registration event - used in app_manager.dart
  Future<void> logCompleteRegistration({String? registrationMethod}) async {
    await _initialize();

    if (Platform.isIOS) {
      // For iOS, use the SKAdNetwork schema
      await _logEventCore(
        name: 'fb_mobile_complete_registration',
        parameters: {
          'registration_method': registrationMethod ?? 'not_specified',
        },
        conversionValue: _registrationConversionValue,
      );
    } else {
      // For Android and other platforms, use the standard API
      await _facebookAppEvents.logCompletedRegistration(
        registrationMethod: registrationMethod,
      );
    }
  }

  // Content view event - used in fortune_view_model.dart
  Future<void> logViewContent({
    required String contentType,
    required String contentId,
    Map<String, dynamic>? parameters,
  }) async {
    final Map<String, dynamic> params = {
      'content_type': contentType,
      'content_id': contentId,
    };

    if (parameters != null) {
      params.addAll(parameters);
    }

    await _logEventCore(
      name: 'fb_mobile_content_view',
      parameters: params,
    );
  }

  // Custom event - used in settings_screen.dart, map_overlay.dart, app_manager.dart
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    await _logEventCore(
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

    // Create base parameters
    final Map<String, dynamic> params = {
      'product_id': productId ?? '',
      'price': price,
    };

    if (parameters != null) {
      params.addAll(parameters);
    }

    if (Platform.isIOS) {
      // For iOS, use SKAdNetwork schema
      await _logEventCore(
        name: 'fb_mobile_purchase',
        parameters: params,
        conversionValue: _purchaseConversionValue,
      );
    } else {
      // For Android and other platforms, use the standard API
      await _facebookAppEvents.logPurchase(
        amount: price,
        currency: currency,
        parameters: params,
      );
    }
  }

  // Simple purchase method - used in fortune_view_model.dart
  Future<void> logPurchaseWithPriceString({
    String? priceString,
    String? productIdentifier,
    Map<String, dynamic>? parameters,
  }) async {
    final Map<String, dynamic> params = {
      'product_id': productIdentifier ?? '',
    };

    if (priceString != null) {
      params['price_string'] = priceString;
    }

    if (parameters != null) {
      params.addAll(parameters);
    }

    await _logEventCore(
      name: 'Purchase',
      parameters: params,
      conversionValue: Platform.isIOS ? _purchaseConversionValue : null,
    );
  }

  // Subscription events
  Future<void> logSubscribe({
    required String subscriptionId,
    double? price,
    String? currency,
    Map<String, dynamic>? parameters,
  }) async {
    await _initialize();

    // Create base parameters
    final Map<String, dynamic> params = {
      'subscription_id': subscriptionId,
    };

    if (price != null) {
      params['price'] = price;
    }

    if (parameters != null) {
      params.addAll(parameters);
    }

    if (Platform.isIOS) {
      // For iOS, use SKAdNetwork schema with conversion value
      await _logEventCore(
        name: 'Subscribe',
        parameters: params,
        conversionValue: _subscriptionConversionValue,
      );
    } else {
      // For Android and other platforms, use standard APIs
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
  }

  // Simple subscription method - used in iap_utils.dart
  Future<void> logSubscribeWithPriceString({
    required String subscriptionId,
    String? priceString,
    Map<String, dynamic>? parameters,
  }) async {
    final Map<String, dynamic> params = {
      'subscription_id': subscriptionId,
    };

    if (priceString != null) {
      params['price_string'] = priceString;
    }

    if (parameters != null) {
      params.addAll(parameters);
    }

    await _logEventCore(
      name: 'Subscribe',
      parameters: params,
      conversionValue: Platform.isIOS ? _subscriptionConversionValue : null,
    );
  }

  // SKAdNetwork conversion value update
  Future<void> updateConversionValue(int value) async {
    if (!Platform.isIOS) return;

    try {
      await _facebookAppEvents.logEvent(
        name: 'fb_mobile_update_conversion_value',
        parameters: {'value': value.toString(), 'schema': _skadNetworkSchema},
      );
      debugPrint('Updated SKAdNetwork conversion value to: $value');
    } catch (e) {
      debugPrint('Error updating SKAdNetwork conversion value: $e');
    }
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
