import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'screens/home.dart';
import 'screens/simple_login.dart';

const int splashDuration = 2;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await DefaultFirebaseOptions.loadEnv();
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
  void _showErrorDialog(String message) {
    if (!mounted) return; // Ensure the widget is still mounted
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handleLogin(String? email, String? password) async {
    if (email == null || password == null) return;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      // Add navigation to HomeScreen if needed
    } on FirebaseAuthException catch (e) {
      if (!mounted) return; // Ensure the widget is still mounted
      _showErrorDialog(e.message ?? 'An error occurred');
    }
  }

  void _handleRegister(String? email, String? password) async {
    if (email == null || password == null) return;
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      // Add navigation to HomeScreen if needed
    } on FirebaseAuthException catch (e) {
      if (!mounted) return; // Ensure the widget is still mounted
      _showErrorDialog(e.message ?? 'An error occurred');
    }
  }

  void _handlePasswordRecovery(String? email) async {
    if (email == null) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return; // Ensure the widget is still mounted
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Password reset email sent. Please check your email.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SimpleLoginScreen()),
                    );
                  });
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return; // Ensure the widget is still mounted
      _showErrorDialog(e.message ?? 'An error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return SimpleLoginScreen(
            onLogin: (email, password) => _handleLogin(email, password),
            onRegister: (email, password) => _handleRegister(email, password),
            onPasswordRecovery: (email) => _handlePasswordRecovery(email),
          );
        }
      },
    );
  }
}
