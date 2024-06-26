import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fortuntella/helpers/show_error.dart';
import 'package:fortuntella/main.dart';
import 'package:fortuntella/repositories/user_repository.dart';
import 'package:fortuntella/repositories/firestore_user_repository.dart';
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
    UserCredential userCredential = await FirebaseAuth.instance
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

    GoogleSignIn googleSignIn = GoogleSignIn(
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

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    if (userCredential.additionalUserInfo?.isNewUser ?? false) {
      await userRepository.addUser(userCredential.user!, {
        'email': userCredential.user?.email,
      });
    }
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return;
    showErrorDialog(context, e.message ?? 'An error occurred');
  } catch (e) {
    if (!context.mounted) return;
    showErrorDialog(context, 'An error occurred while signing in with Google.');
  }
}

Future<void> handleSignOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.disconnect();

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  } catch (e) {
    showErrorDialog(context, 'An error occurred while signing out.');
  }
}
