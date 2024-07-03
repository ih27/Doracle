import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'helpers/constants.dart';
import 'helpers/show_snackbar.dart';
import 'repositories/firestore_user_repository.dart';
import 'screens/main_screen.dart';
import 'screens/simple_login_screen.dart';
import 'services/firestore_service.dart';
import 'services/user_service.dart';

final UserService userService = UserService(FirestoreUserRepository());

User? currentUser() {
  return FirebaseAuth.instance.currentUser;
}

Future<void> handleLogin(
    BuildContext context, String? email, String? password) async {
  if (email == null || password == null) return;
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    if (!context.mounted) return;
    showInfoSnackBar(context, InfoMessages.loginSuccess);
  } on FirebaseAuthException {
    if (!context.mounted) return;
    showErrorSnackBar(context, InfoMessages.loginFailure);
  }
}

Future<void> handleRegister(
    BuildContext context, String? email, String? password) async {
  if (email == null || password == null) return;
  try {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await userService.addUser(userCredential.user!.uid, {
      'email': email,
    });
    if (!context.mounted) return;
    showInfoSnackBar(context, InfoMessages.registerSuccess);
  } on FirebaseAuthException {
    if (!context.mounted) return;
    showErrorSnackBar(context, InfoMessages.registerFailure);
  }
}

Future<void> handlePasswordRecovery(BuildContext context, String? email) async {
  if (email == null || email.trim().isEmpty) {
    showErrorSnackBar(context, InfoMessages.invalidEmailAddress);
    return;
  }

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    if (!context.mounted) return;
    showInfoSnackBar(context, InfoMessages.passwordReset);
  } on FirebaseAuthException {
    if (!context.mounted) return;
    // Generic message to user, regardless of the specific error
    showInfoSnackBar(context, InfoMessages.passwordReset);
  } catch (e) {
    if (!context.mounted) return;
    showErrorSnackBar(context, InfoMessages.passwordResetFailure);
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
    if (!context.mounted) return;
    showInfoSnackBar(context, InfoMessages.loginSuccess);
  } catch (e) {
    if (!context.mounted) return;
    showErrorSnackBar(context, InfoMessages.loginFailure);
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
    if (!context.mounted) return;
    showInfoSnackBar(context, InfoMessages.loginSuccess);
  } catch (e) {
    if (!context.mounted) return;
    showErrorSnackBar(context, InfoMessages.loginFailure);
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
    showInfoSnackBar(context, InfoMessages.logoutSuccess);
  } catch (e) {
    if (!context.mounted) return;
    showErrorSnackBar(context, InfoMessages.logoutFailure);
  }
}

Future<void> _associateEmailWith(UserCredential userCredential) async {
  if (userCredential.additionalUserInfo?.isNewUser ?? false) {
    await userService.addUser(userCredential.user!.uid, {
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
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        // User is signed in, initialize Firestore cache in the background
        await FirestoreService.initializeQuestionsCache();
      }
    });
  }

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
