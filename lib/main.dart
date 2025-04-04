import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'config/notifications.dart';
import 'config/dependency_injection.dart';
import 'config/firebase_options.dart';
import 'config/theme.dart';
import 'app_manager.dart';
import 'global_key.dart';
import 'providers/entitlement_provider.dart';
import 'services/crashlytics_service.dart';
import 'services/firestore_service.dart';
import 'services/haptic_service.dart';
import 'services/unified_analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Setup dependencies early so we can use CrashlyticsService for error reporting
  setupDependencies();

  await _setupErrorReporting();

  // Request App Tracking Transparency permission early - BEFORE any analytics are initialized
  await _requestAppTrackingPermission();

  // Activate App Check
  await FirebaseAppCheck.instance.activate(
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck);

  await setupNotifications();

  // Create and initialize EntitlementProvider first
  final entitlementProvider = getIt<EntitlementProvider>();

  // Initialize all app services
  await _initializeApp();

  runApp(
    ChangeNotifierProvider.value(
      // Use .value to reuse the same instance
      value: entitlementProvider,
      child: const MyApp(),
    ),
  );
  cleanUpNotifications();
}

Future<void> _setupErrorReporting() async {
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  // Disable collecting thread and stack information which may be causing the crash
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  await FirebaseCrashlytics.instance.setCustomKey('collectThreads', false);

  // Get the CrashlyticsService from dependency injection
  final crashlyticsService = getIt<CrashlyticsService>();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    try {
      crashlyticsService.recordFlutterError(errorDetails);
    } catch (e) {
      debugPrint('Error reporting to Crashlytics: $e');
    }
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      crashlyticsService.recordError(error, stack, fatal: true);
    } catch (e) {
      debugPrint('Error reporting to Crashlytics: $e');
    }
    return true;
  };
}

Future<void> _initializeApp() async {
  // Initialize analytics services
  final analytics = getIt<UnifiedAnalyticsService>();
  await analytics.initialize();

  // Initialize HapticService early
  await getIt<HapticService>().initialize();

  // Initialize RevenueCat and check entitlements
  try {
    final entitlementProvider = getIt<EntitlementProvider>();
    await entitlementProvider.checkEntitlementStatus();
  } catch (e) {
    debugPrint('Error initializing RevenueCat: $e');
    // Don't rethrow - we want the app to continue even if RevenueCat fails
  }

  // Random questions cache initialization
  await FirebaseAuth.instance.authStateChanges().first;
  if (FirebaseAuth.instance.currentUser != null) {
    await FirestoreService.initializeQuestionsCache();
  }
}

// Request App Tracking Transparency permission before any tracking occurs
Future<bool> _requestAppTrackingPermission() async {
  if (Platform.isIOS) {
    debugPrint('Requesting App Tracking Transparency permission');

    final status = await Permission.appTrackingTransparency.request();
    debugPrint('ATT Permission status: ${status.toString()}');
    return status.isGranted;
  }
  return false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Doracle',
      theme: AppTheme.lightTheme,
      home: Container(
        color: AppTheme.primaryBackground,
        child: const AppManager(),
      ),
    );
  }
}
