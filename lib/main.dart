import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/notifications.dart';
import 'config/dependency_injection.dart';
import 'config/firebase_options.dart';
import 'config/theme.dart';
import 'app_manager.dart';
import 'services/haptic_service.dart';
import 'services/question_cache_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _setupErrorReporting();

  // Activate App Check
  await FirebaseAppCheck.instance.activate(
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck);

  await setupNotifications();
  setupDependencies();
  await _initializeApp();
  runApp(const MyApp());
}

Future<void> _setupErrorReporting() async {
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> _initializeApp() async {
  // Initialize HapticService early
  await getIt<HapticService>().initialize();

  // Random questions cache initialization
  await FirebaseAuth.instance.authStateChanges().first;
  if (FirebaseAuth.instance.currentUser != null) {
    try {
      await getIt<QuestionCacheService>().initializeCache();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doracle',
      theme: AppTheme.lightTheme,
      home: Container(
        color: AppTheme.primaryBackground,
        child: AppManager(),
      ),
    );
  }
}
