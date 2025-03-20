import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// A service that safely handles error reporting to Firebase Crashlytics
/// by sanitizing error objects and stack traces before sending
class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Safely record an error to Crashlytics, handling edge cases
  Future<void> recordError(dynamic error, StackTrace? stack,
      {bool fatal = false}) async {
    try {
      // Convert error to string if it's a complex object that might cause issues
      final errorMessage = error.toString();

      // Create a sanitized version of the error
      final sanitizedError = error is Error ? error : Exception(errorMessage);

      // Use a dummy stack trace if none provided
      final stackTrace = stack ?? StackTrace.current;

      // Record with the sanitized values
      await _crashlytics.recordError(
        sanitizedError,
        stackTrace,
        fatal: fatal,
      );
    } catch (e) {
      // If Crashlytics itself crashes, just log locally
    }
  }

  /// Safely record a Flutter error to Crashlytics
  Future<void> recordFlutterError(FlutterErrorDetails errorDetails) async {
    try {
      await _crashlytics.recordFlutterFatalError(errorDetails);
    } catch (e) {
      // If Crashlytics recording fails, extract key info and try a simpler approach
      try {
        // Try recording just the exception and stack trace instead
        await _crashlytics.recordError(
          errorDetails.exception,
          errorDetails.stack ?? StackTrace.current,
          reason: errorDetails.context?.toString(),
          fatal: true,
        );
      } catch (e2) {
        // If that also fails, just log locally
      }
    }
  }
}
