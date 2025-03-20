import 'package:flutter/foundation.dart';
import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdjustService {
  // Get Adjust app token from .env file
  final String _appToken = dotenv.env['ADJUST_APP_TOKEN'] ?? '';
  bool _isInitialized = false;

  /// Initialize Adjust SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (_appToken.isEmpty) {
      // Warning: ADJUST_APP_TOKEN is missing from .env file
      return;
    }

    // Create config
    const environment =
        kDebugMode ? AdjustEnvironment.sandbox : AdjustEnvironment.production;

    final config = AdjustConfig(_appToken, environment);

    // Set logging level for debug mode
    if (kDebugMode) {
      config.logLevel = AdjustLogLevel.verbose;
    }

    // Initialize the SDK
    Adjust.initSdk(config);
    _isInitialized = true;
  }

  /// Track a custom event
  Future<void> trackEvent(String eventToken,
      {Map<String, String>? callbackParameters,
      Map<String, String>? partnerParameters}) async {
    if (!_isInitialized) {
      // Warning: Adjust SDK not initialized
      return;
    }

    final event = AdjustEvent(eventToken);

    // Add callback parameters if provided
    if (callbackParameters != null) {
      callbackParameters.forEach((key, value) {
        event.addCallbackParameter(key, value);
      });
    }

    // Add partner parameters if provided
    if (partnerParameters != null) {
      partnerParameters.forEach((key, value) {
        event.addPartnerParameter(key, value);
      });
    }

    Adjust.trackEvent(event);
  }

  /// Track revenue event
  Future<void> trackRevenue(String eventToken, double amount, String currency,
      {Map<String, String>? callbackParameters,
      Map<String, String>? partnerParameters}) async {
    if (!_isInitialized) {
      // Warning: Adjust SDK not initialized
      return;
    }

    final event = AdjustEvent(eventToken);
    event.setRevenue(amount, currency);

    // Add callback parameters if provided
    if (callbackParameters != null) {
      callbackParameters.forEach((key, value) {
        event.addCallbackParameter(key, value);
      });
    }

    // Add partner parameters if provided
    if (partnerParameters != null) {
      partnerParameters.forEach((key, value) {
        event.addPartnerParameter(key, value);
      });
    }

    Adjust.trackEvent(event);
  }
}
