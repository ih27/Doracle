import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dependency_injection.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';
import 'services/question_cache_service.dart';
import 'theme.dart';
import 'controllers/purchases.dart';

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

  await _setupNotifications();
  setupDependencies();  
  await _initializeApp();
  runApp(const MyApp());
}

Future<void> _setupNotifications() async {
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  debugPrint('Notifications permission: ${settings.authorizationStatus}');
  // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) {
    debugPrint("My APN token: $apnsToken");
  }
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
  // Purchase related initialization
  await getIt<PurchasesController>().initialize();
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
        child: AuthWrapper(),
      ),
    );
  }
}
