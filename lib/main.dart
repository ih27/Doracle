import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
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

  // Activate App Check
  await FirebaseAppCheck.instance.activate(
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck);

  await setupNotifications();
  await _initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => getIt<EntitlementProvider>(),
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
  // Initialize Unified Analytics Service (handles all analytics initialization)
  await getIt<UnifiedAnalyticsService>().initialize();

  // Initialize HapticService early
  await getIt<HapticService>().initialize();

  // Random questions cache initialization
  await FirebaseAuth.instance.authStateChanges().first;
  if (FirebaseAuth.instance.currentUser != null) {
    await FirestoreService.initializeQuestionsCache();
  }
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
