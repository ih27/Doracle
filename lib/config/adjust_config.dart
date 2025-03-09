/// Adjust Event Token Configuration
///
/// This file contains constants for all Adjust event tokens used in the app.
class AdjustEvents {
  // Conversion Events (Revenue)
  static const String purchase = 'hv6sup';
  static const String subscription = 'chaz8s';

  // Attribution Events
  static const String registration = 'c19yvd';
  static const String login = 'opj22l';
  static const String tutorialComplete = '81nty1';

  // Optional Events
  static const String rateApp = 'rhe7js';
  static const String locationSearch = 'a04aat';
}

/// SKAdNetwork Conversion Values (iOS Only)
///
/// These values are used for iOS 14+ SKAdNetwork attribution
/// Reference: https://help.adjust.com/en/article/skadnetwork-conversion-values
class AdjustConversionValues {
  static const int registration = 2;
  static const int tutorialCompletion = 1;
  static const int purchase = 4;
  static const int subscription = 6;
}
