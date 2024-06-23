import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'screens/simple_login_screen.dart';

void showErrorDialog(BuildContext context, String message) {
  if (!context.mounted) return; // Ensure the widget is still mounted
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

Future<void> handleLogin(BuildContext context, String? email, String? password) async {
  if (email == null || password == null) return;
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return; // Ensure the widget is still mounted
    showErrorDialog(context, e.message ?? 'An error occurred');
  }
}

Future<void> handleRegister(BuildContext context, String? email, String? password) async {
  if (email == null || password == null) return;
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    // Add user data to Firestore
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
      'email': email,
      'createdAt': Timestamp.now(),
    });
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return; // Ensure the widget is still mounted
    showErrorDialog(context, e.message ?? 'An error occurred');
  }
}

Future<void> handlePasswordRecovery(BuildContext context, String? email) async {
  if (email == null) return;
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    if (!context.mounted) return; // Ensure the widget is still mounted
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SimpleLoginScreen()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return; // Ensure the widget is still mounted
    showErrorDialog(context, e.message ?? 'An error occurred');
  }
}

Future<void> handleGoogleSignIn(BuildContext context) async {
  try {
    const List<String> scopes = <String>[
      'email', 'profile', 'openid'
    ];

    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: scopes,
    );
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
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
    if (!context.mounted) return;
    showErrorDialog(context, e.message ?? 'An error occurred');
  } catch (e) {
    if (!context.mounted) return;
    showErrorDialog(context, 'An error occurred while signing in with Google.');
  }
}
