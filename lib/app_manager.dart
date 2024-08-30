import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'config/dependency_injection.dart';
import 'entities/entity_manager.dart';
import 'helpers/constants.dart';
import 'helpers/show_snackbar.dart';
import 'models/owner_model.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tutorial_screen.dart';
import 'services/analytics_service.dart';
import 'services/auth_service.dart';
import 'services/first_launch_service.dart';
import 'services/revenuecat_service.dart';
import 'services/user_service.dart';
import 'widgets/initial_owner_create.dart';

class AppManager extends StatelessWidget {
  final AuthService _authService = getIt<AuthService>();
  final UserService _userService = getIt<UserService>();
  final OwnerManager _ownerManager = getIt<OwnerManager>();
  final AnalyticsService _analytics = getIt<AnalyticsService>();
  final RevenueCatService _revenueCatService = getIt<RevenueCatService>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  AppManager({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: FirstLaunchService.isFirstLaunch(),
      builder: (context, firstLaunchSnapshot) {
        if (firstLaunchSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final isFirstLaunch = firstLaunchSnapshot.data ?? true;

        return StreamBuilder<User?>(
          stream: _authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              debugPrint('Auth userId: ${snapshot.data!.uid}');
              return FutureBuilder(
                future: _loadUser(snapshot.data!.uid),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return FutureBuilder<bool>(
                      future: _checkOwnerExists(),
                      builder: (context, ownerSnapshot) {
                        if (ownerSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (ownerSnapshot.data == true) {
                          return const SafeArea(child: MainScreen());
                        } else {
                          // Use a post-frame callback to navigate
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _handleInitialOwnerCreation(context);
                          });
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    );
                  }
                },
              );
            } else {
              return Navigator(
                key: navigatorKey,
                initialRoute: isFirstLaunch ? '/tutorial' : '/splash',
                onGenerateRoute: (settings) {
                  Widget page;
                  switch (settings.name) {
                    case '/tutorial':
                      page = TutorialScreen(
                        onComplete: _completeTutorial,
                      );
                      break;
                    case '/splash':
                      page = SplashScreen(
                        onSignIn: _navigateToSignIn,
                        onSignUp: _navigateToSignUp,
                      );
                      break;
                    case '/login':
                      page = LoginScreen(
                        onLogin: _handleLogin,
                        onPasswordRecovery: _handlePasswordRecovery,
                        onPlatformSignIn: _handlePlatformSignIn,
                        onNavigateToSignUp: _navigateToSignUp,
                      );
                      break;
                    case '/register':
                      page = RegisterScreen(
                        onRegister: _handleRegister,
                        onPlatformSignIn: _handlePlatformSignIn,
                        onNavigateToSignIn: _navigateToSignIn,
                      );
                      break;
                    default:
                      page = const SizedBox.shrink();
                  }
                  return MaterialPageRoute(builder: (_) => page);
                },
              );
            }
          },
        );
      },
    );
  }

  Future<void> _completeTutorial() =>
      FirstLaunchService.setFirstLaunchComplete();

  Future<void> _navigateToSignIn() =>
      navigatorKey.currentState!.pushNamed('/login');

  Future<void> _navigateToSignUp() =>
      navigatorKey.currentState!.pushNamed('/register');

  Future<bool> _checkOwnerExists() async {
    await _ownerManager.loadEntities();
    return _ownerManager.entities.isNotEmpty;
  }

  Future<void> _handleInitialOwnerCreation(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InitialOwnerCreationScreen(),
      ),
    );

    if (result is Owner) {
      await _ownerManager.addEntity(result);
      if (context.mounted) {
        showInfoSnackBar(context, CompatibilityTexts.createOwnerSuccess);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (_) => const SafeArea(child: MainScreen())),
          );
        });
      }
    }
  }

  Future<void> _loadUser(String userId) async {
    await _userService.loadCurrentUser(userId);
    _initializeRevenueCat(userId);
  }

  void _initializeRevenueCat(String userId) {
    const int maxRetries = 3;
    const Duration retryDelay = Duration(minutes: 1);
    int retryCount = 0;

    Future<void> attemptInitialization() async {
      try {
        await _revenueCatService.initializeAndLogin(userId);
      } catch (e) {
        debugPrint('RevenueCat initialization error: $e');
        if (retryCount < maxRetries) {
          retryCount++;
          Timer(retryDelay, attemptInitialization);
        } else {
          _analytics.logEvent(
              name: 'revenuecat_init_failed', parameters: {'userId': userId});
        }
      }
    }

    attemptInitialization();
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
      UserCredential? userCredential =
          await _authService.handlePlatformSignIn();

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
