/// Adjust Event Token Configuration
///
/// This file contains constants for all Adjust event tokens used in the app.
/// Replace sample tokens with actual tokens from your Adjust dashboard.
class AdjustEvents {
  // Conversion Events (Revenue)
  static const String purchase = 'abc123def456'; // Replace with actual token
  static const String subscription =
      'xyz789uvw012'; // Replace with actual token

  // Attribution Events
  static const String registration =
      'reg345token678'; // Replace with actual token
  static const String login = 'log901token234'; // Replace with actual token
  static const String tutorialComplete =
      'tut567token890'; // Replace with actual token

  // Optional Events
  static const String rateApp = 'rat123token456'; // Replace with actual token
  static const String locationSearch =
      'loc789token012'; // Replace with actual token
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
