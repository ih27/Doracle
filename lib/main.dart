import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/simple_login_screen.dart';
import 'auth_handlers.dart';

const int splashDuration = 2;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Future.delayed(const Duration(seconds: splashDuration));

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
    ));
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return HomeScreen(
            onLogout: () => handleSignOut(context),
          );
        } else {
          return SimpleLoginScreen(
            onLogin: (email, password) => handleLogin(context, email, password),
            onRegister: (email, password) =>
                handleRegister(context, email, password),
            onPasswordRecovery: (email) =>
                handlePasswordRecovery(context, email),
            onGoogleSignIn: () => handleGoogleSignIn(context),
          );
        }
      },
    );
  }
}
