import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    } on FirebaseAuthException catch (e) {
      if (!mounted) return; // Ensure the widget is still mounted
      _showErrorDialog(e.message ?? 'An error occurred');
    }
  }

  void _handleRegister(String? email, String? password) async {
    if (email == null || password == null) return;
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      // Add user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'createdAt': Timestamp.now(),
      });
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

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Add user data to Firestore if it's a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
          'email': userCredential.user?.email,
          'createdAt': Timestamp.now(),
        });
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.message ?? 'An error occurred');
    } catch (e) {
      _showErrorDialog('An error occurred while signing in with Google.');
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
            onGoogleSignIn: _handleGoogleSignIn,
          );
        }
      },
    );
  }
}
