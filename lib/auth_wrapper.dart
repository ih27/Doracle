import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fortuntella/helpers/constants.dart';
import 'dependency_injection.dart';
import 'helpers/show_snackbar.dart';
import 'screens/main_screen.dart';
import 'screens/simple_login_screen.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = getIt<AuthService>();
  final UserService _userService = getIt<UserService>();

  AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        debugPrint('Auth state changed: ${snapshot.data?.uid}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return FutureBuilder(
              future: _loadUser(snapshot.data!.uid),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  debugPrint('User loaded, navigating to MainScreen');
                  return const SafeArea(child: MainScreen());
                }
              });
        } else {
          return SimpleLoginScreen(
            onLogin: (email, password) =>
                _handleLogin(context, email, password),
            onRegister: (email, password) =>
                _handleRegister(context, email, password),
            onPasswordRecovery: (email) =>
                _handlePasswordRecovery(context, email),
            onPlatformSignIn: () => _handlePlatformSignIn(context),
          );
        }
      },
    );
  }

  Future<void> _loadUser(String userId) async {
    debugPrint('_loadUser called with userId: $userId');
    await _userService.loadCurrentUser(userId);
  }

  Future<void> _handleLogin(
      BuildContext context, String? email, String? password) async {
    if (email == null || password == null) return;
    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, InfoMessages.loginFailure);
      }
    }
  }

  Future<bool>  _handleRegister(
      BuildContext context, String? email, String? password) async {
    if (email == null || password == null) return false;
    try {
      await _authService.createUserWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, InfoMessages.registerFailure);
      }
      return false;
    }
  }

  Future<void> _handlePasswordRecovery(
      BuildContext context, String? email) async {
    if (email == null || email.trim().isEmpty) {
      showErrorSnackBar(context, InfoMessages.invalidEmailAddress);
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email.trim());
      if (context.mounted) {
        showInfoSnackBar(context, InfoMessages.passwordReset);
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, InfoMessages.passwordResetFailure);
      }
    }
  }

  Future<bool> _handlePlatformSignIn(BuildContext context) async {
    try {
      await _authService.handlePlatformSignIn();
      return true;
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, InfoMessages.loginFailure);
      }
      return false;
    }
  }
}
