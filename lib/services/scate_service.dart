import 'package:flutter/foundation.dart';
import 'package:scatesdk_flutter/scatesdk_flutter.dart';
import 'package:adjust_sdk/adjust.dart';

class ScateService {
  final String _appId;
  bool _isInitialized = false;

  ScateService({required String appId}) : _appId = appId;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize ScateSDK
      ScateSDK.Init(_appId);

      // Set ADID from Adjust
      final String? adid = await Adjust.getAdid();
      if (adid != null) {
        ScateSDK.SetAdid(adid);
      }

      _isInitialized = true;
      debugPrint('ScateSDK initialized successfully');
    } catch (e) {
      debugPrint('Error initializing ScateSDK: $e');
    }
  }

  // Event tracking methods
  void trackEvent(String eventName) {
    if (!_isInitialized) {
      debugPrint('Warning: ScateSDK not initialized');
      return;
    }
    ScateSDK.Event(eventName);
  }

  void trackEventWithValue(String eventName, String value) {
    if (!_isInitialized) {
      debugPrint('Warning: ScateSDK not initialized');
      return;
    }
    ScateSDK.EventWithValue(eventName, value);
  }

  // Onboarding tracking
  void trackOnboardingStart() => ScateSDK.OnboardingStart();
  void trackOnboardingStep(String step) => ScateSDK.OnboardingStep(step);
  void trackOnboardingFinish() => ScateSDK.OnboardingFinish();

  // Login tracking
  void trackLoginSuccess(String method) => ScateSDK.LoginSuccess(method);

  // Ad tracking
  void trackInterstitialAdShown() => ScateSDK.InterstitialAdShown();
  void trackInterstitialAdClosed() => ScateSDK.InterstitialAdClosed();
  void trackRewardedAdShown() => ScateSDK.RewardedAdShown();
  void trackRewardedAdClosed() => ScateSDK.RewardedAdClosed();
  void trackRewardedAdClaimed() => ScateSDK.RewardedAdClaimed();
  void trackBannerAdShown() => ScateSDK.BannerAdShown();

  // Permission tracking
  void trackNotificationPermissionGranted() =>
      ScateSDK.NotificationPermissionGranted();
  void trackNotificationPermissionDenied() =>
      ScateSDK.NotificationPermissionDenied();
  void trackLocationPermissionGranted() => ScateSDK.LocationPermissionGranted();
  void trackLocationPermissionDenied() => ScateSDK.LocationPermissionDenied();
  void trackATTPromptShown() => ScateSDK.ATTPromptShown();
  void trackATTPermissionGranted() => ScateSDK.ATTPermissionGranted();
  void trackATTPermissionDenied() => ScateSDK.ATTPermissionDenied();

  // Paywall tracking
  void trackPaywallShown(String name) => ScateSDK.PaywallShown(name);
  void trackPaywallClosed(String name) => ScateSDK.PaywallClosed(name);
  void trackPaywallAttempted(String name) => ScateSDK.PaywallAttempted(name);
  void trackPaywallPurchased(String name) => ScateSDK.PaywallPurchased(name);
  void trackPaywallCancelled(String name) => ScateSDK.PaywallCancelled(name);

  // Feature tracking
  void trackTabClicked(String tab) => ScateSDK.TabClicked(tab);
  void trackFeatureClicked(String feature) => ScateSDK.FeatureClicked(feature);

  // Daily streak tracking
  void trackDailyStreakShown() => ScateSDK.DailyStreakShown();
  void trackDailyStreakClaimed() => ScateSDK.DailyStreakClaimed();
  void trackDailyStreakClosed() => ScateSDK.DailyStreakClosed();

  // Remote config
  Future<String> getRemoteConfig(String key, String defaultValue) async {
    final result = await ScateSDK.GetRemoteConfig(key, defaultValue);
    return result ?? defaultValue;
  }

  // Event listeners
  void addListener(ScateEvents event, Function(dynamic) callback) {
    ScateSDK.AddListener(event, callback);
  }

  void removeListener(ScateEvents event) {
    ScateSDK.RemoveListener(event);
  }

  void cleanListeners() {
    // Note: CleanListeners is not available in the SDK, so we'll just remove all known listeners
    for (var event in ScateEvents.values) {
      ScateSDK.RemoveListener(event);
    }
  }
}
