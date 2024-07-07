import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dependency_injection.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart';
import 'services/firestore_service.dart';
import 'theme.dart';
import 'controllers/purchases.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  // Portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Activate App Check
  await FirebaseAppCheck.instance.activate();

  // Set up GetIt dependencies and initialize important components
  setupDependencies();
  await getIt<PurchasesController>().initialize();
  await _initializeApp();

  runApp(const MyApp());
  FlutterNativeSplash.remove();
}

Future<void> _initializeApp() async {
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
      title: 'Doracle',
      theme: AppTheme.lightTheme,
      home: Container(
        color: AppTheme.getColorFromHex("#fbf9f5"),
        child: AuthWrapper(),
      ),
    );
  }
}
