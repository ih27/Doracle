import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fortuntella/screens/main_screen.dart';
import 'firebase_options.dart';
import 'screens/simple_login_screen.dart';
import 'auth_handlers.dart';

const int splashDuration = 1;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase and dotenv in parallel
  await Future.wait([
    dotenv.load(fileName: ".env"),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  await Future.delayed(const Duration(seconds: splashDuration));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SafeArea(
        child: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  void _handlePlatformSignIn(BuildContext context) {
    if (Platform.isAndroid) {
      handleGoogleSignIn(context);
    } else if (Platform.isIOS) {
      handleAppleSignIn(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const MainScreen();
        } else {
          return SimpleLoginScreen(
            onLogin: (email, password) => handleLogin(context, email, password),
            onRegister: (email, password) =>
                handleRegister(context, email, password),
            onPasswordRecovery: (email) =>
                handlePasswordRecovery(context, email),
            onPlatformSignIn: () => _handlePlatformSignIn(context),
          );
        }
      },
    );
  }
}
