import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'config/dependency_injection.dart';
import 'helpers/constants.dart';
import 'helpers/show_snackbar.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'services/analytics_service.dart';
import 'services/auth_service.dart';
import 'services/revenuecat_service.dart';
import 'services/user_service.dart';

class AppManager extends StatelessWidget {
  final AuthService _authService = getIt<AuthService>();
  final UserService _userService = getIt<UserService>();
  final AnalyticsService _analytics = getIt<AnalyticsService>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  AppManager({super.key});

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
                page = LoginScreen(
                  onLogin: _handleLogin,
                  onPasswordRecovery: _handlePasswordRecovery,
                  onPlatformSignIn: _handlePlatformSignIn,
                  onNavigateToSignUp: _navigateToSignUp,
                );
              } else if (settings.name == '/register') {
                page = RegisterScreen(
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
    await _userService.loadCurrentUser(userId);
    await getIt<RevenueCatService>().initializeAndLogin(userId);
  }

  Future<void> _handleLogin(String? email, String? password) async {
    if (email == null || password == null) return;
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      _analytics.logLogin(loginMethod: 'email');
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
      _analytics.logSignUp(signUpMethod: 'email');
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
      UserCredential? userCredential = await _authService.handlePlatformSignIn();

      // Check if the user is new
      if (userCredential?.additionalUserInfo?.isNewUser ?? false) {
        _analytics.logSignUp(signUpMethod: Platform.isIOS ? 'apple' : 'google');
      } else {
        _analytics.logLogin(loginMethod: Platform.isIOS ? 'apple' : 'google');
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, InfoMessages.loginFailure);
      }
    }
  }
}
