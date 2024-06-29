import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../helpers/show_error.dart';
import '../repositories/user_repository.dart';
import '../repositories/firestore_user_repository.dart';
import 'screens/main_screen.dart';
import 'screens/simple_login_screen.dart';

final UserRepository userRepository = FirestoreUserRepository();

Future<void> handleLogin(
    BuildContext context, String? email, String? password) async {
  if (email == null || password == null) return;
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return;
    showErrorDialog(context, e.message ?? 'An error occurred');
  }
}

Future<void> handleRegister(
    BuildContext context, String? email, String? password) async {
  if (email == null || password == null) return;
  try {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await userRepository.addUser(userCredential.user!, {
      'email': email,
    });
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return;
    showErrorDialog(context, e.message ?? 'An error occurred');
  }
}

Future<void> handlePasswordRecovery(BuildContext context, String? email) async {
  if (email == null) return;
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content:
              const Text('Password reset email sent. Please check your email.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SimpleLoginScreen()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return;
    showErrorDialog(context, e.message ?? 'An error occurred');
  }
}

Future<void> handleGoogleSignIn(BuildContext context) async {
  try {
    const List<String> scopes = <String>['email', 'profile', 'openid'];

    final googleSignIn = GoogleSignIn(
      scopes: scopes,
    );
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    await _associateEmailWith(userCredential);
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return;
    showErrorDialog(context, e.message ?? 'An error occurred');
  } catch (e) {
    if (!context.mounted) return;
    showErrorDialog(context, 'An error occurred while signing in with Google.');
  }
}

Future<void> handleAppleSignIn(BuildContext context) async {
  try {
    final appleProvider = AppleAuthProvider()
      ..addScope('name')
      ..addScope('email');
    final userCredential =
        await FirebaseAuth.instance.signInWithProvider(appleProvider);

    await _associateEmailWith(userCredential);
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return;
    showErrorDialog(context, e.message ?? 'An error occurred');
  } catch (e) {
    if (!context.mounted) return;
    showErrorDialog(context, 'An error occurred while signing in with Apple.');
  }
}

Future<void> handleSignOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();

    if (Platform.isAndroid) {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.disconnect();
    }

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  } catch (e) {
    showErrorDialog(context, 'An error occurred while signing out.');
  }
}

Future<void> _associateEmailWith(UserCredential userCredential) async {
  if (userCredential.additionalUserInfo?.isNewUser ?? false) {
    await userRepository.addUser(userCredential.user!, {
      'email': userCredential.user?.email,
    });
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
