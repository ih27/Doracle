import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dependency_injection.dart';
import 'helpers/constants.dart';
import 'helpers/show_snackbar.dart';
import 'screens/main_screen.dart';
import 'screens/simple_login_screen.dart';
import 'screens/simple_register_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = getIt<AuthService>();
  final UserService _userService = getIt<UserService>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
                return const SafeArea(child: MainScreen());
              }
            },
          );
        } else {
          return Navigator(
            key: navigatorKey,
            onGenerateRoute: (settings) {
              Widget page;
              if (settings.name == '/login') {
                page = SimpleLoginScreen(
                  onLogin: _handleLogin,
                  onPasswordRecovery: _handlePasswordRecovery,
                  onPlatformSignIn: _handlePlatformSignIn,
                  onNavigateToSignUp: _navigateToSignUp,
                );
              } else if (settings.name == '/register') {
                page = SimpleRegisterScreen(
                  onRegister: _handleRegister,
                  onPlatformSignIn: _handlePlatformSignIn,
                  onNavigateToSignIn: _navigateToSignIn,
                );
              } else {
                page = SplashScreen(
                  onSignIn: _navigateToSignIn,
                  onSignUp: _navigateToSignUp,
                );
              }
              return MaterialPageRoute(builder: (_) => page);
            },
          );
        }
      },
    );
  }

  Future<void> _navigateToSignIn() =>
      navigatorKey.currentState!.pushNamed('/login');

  Future<void> _navigateToSignUp() =>
      navigatorKey.currentState!.pushNamed('/register');

  Future<void> _loadUser(String userId) async {
    debugPrint('_loadUser called with userId: $userId');
    await _userService.loadCurrentUser(userId);
  }

  Future<void> _handleLogin(String? email, String? password) async {
    if (email == null || password == null) return;
    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      BuildContext context = navigatorKey.currentContext!;
      if (context.mounted) {
        showErrorSnackBar(context, InfoMessages.loginFailure);
      }
    }
  }

  Future<void> _handleRegister(String? email, String? password) async {
    if (email == null || password == null) return;
    try {
      await _authService.createUserWithEmailAndPassword(email, password);
    } catch (e) {
      BuildContext context = navigatorKey.currentContext!;
      if (context.mounted) {
        showErrorSnackBar(context, InfoMessages.registerFailure);
      }
    }
  }

  Future<void> _handlePasswordRecovery(String? email) async {
    BuildContext context = navigatorKey.currentContext!;
    if (email == null || email.trim().isEmpty) {
      if (context.mounted) {
        showErrorSnackBar(context, InfoMessages.invalidEmailAddress);
      }
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

  Future<void> _handlePlatformSignIn() async {
    BuildContext context = navigatorKey.currentContext!;
    try {
      await _authService.handlePlatformSignIn();
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, InfoMessages.loginFailure);
      }
    }
  }
}
