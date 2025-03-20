import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'config/dependency_injection.dart';
import 'config/theme.dart';
import 'entities/entity_manager.dart';
import 'global_key.dart';
import 'helpers/constants.dart';
import 'helpers/show_snackbar.dart';
import 'models/owner_model.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tutorial_screen.dart';
import 'services/auth_service.dart';
import 'services/first_launch_service.dart';
import 'services/revenuecat_service.dart';
import 'services/user_service.dart';
import 'services/unified_analytics_service.dart';
import 'widgets/initial_owner_create.dart';
import 'services/firestore_service.dart';

class AppManager extends StatefulWidget {
  const AppManager({super.key});

  @override
  State<AppManager> createState() => _AppManagerState();
}

class _AppManagerState extends State<AppManager> {
  final AuthService _authService = getIt<AuthService>();
  final UserService _userService = getIt<UserService>();
  final OwnerManager _ownerManager = getIt<OwnerManager>();
  final UnifiedAnalyticsService _analytics = getIt<UnifiedAnalyticsService>();
  final RevenueCatService _revenueCatService = getIt<RevenueCatService>();

  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    // DEBUG
    // await _authService.signOut();
    // await FirstLaunchService.resetFirstLaunch();
    // await _ownerManager.removeEntities();
    // DEBUG END
    final isFirstLaunch = await FirstLaunchService.isFirstLaunch();
    setState(() {
      _isFirstLaunch = isFirstLaunch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ));
        } else if (snapshot.hasData) {
          // User authenticated with ID: ${snapshot.data!.uid}
          return FutureBuilder(
            future: _loadUser(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ));
              } else {
                return FutureBuilder<bool>(
                  future: _checkOwnerExists(),
                  builder: (context, ownerSnapshot) {
                    if (ownerSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ));
                    } else if (ownerSnapshot.data == true) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        navigatorKey.currentState?.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                          (route) => false,
                        );
                      });
                      return const SizedBox.shrink();
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _handleInitialOwnerCreation(context);
                      });
                      return const Center(
                          child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ));
                    }
                  },
                );
              }
            },
          );
        } else {
          if (_isFirstLaunch) {
            return TutorialScreen(
              onComplete: _completeTutorial,
              onSignIn: () => _navigateToSignIn(context, isFromTutorial: true),
              onSignUp: () => _navigateToSignUp(context, isFromTutorial: true),
            );
          } else {
            return SplashScreen(
              onSignIn: () => _navigateToSignIn(context, isFromTutorial: false),
              onSignUp: () => _navigateToSignUp(context, isFromTutorial: false),
            );
          }
        }
      },
    );
  }

  Future<void> _completeTutorial() async {
    await FirstLaunchService.setFirstLaunchComplete();
    setState(() {
      _isFirstLaunch = false;
    });

    // Log tutorial completion to analytics (non-blocking)
    _analytics.logEvent(
      name: 'tutorial_complete',
      parameters: {'method': 'normal'},
    );
  }

  Future<void> _navigateToSignIn(BuildContext context,
      {required bool isFromTutorial}) async {
    if (isFromTutorial) {
      await _completeTutorial();
    }
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          onLogin: (email, password) => _handleLogin(context, email, password),
          onPasswordRecovery: (email) =>
              _handlePasswordRecovery(context, email),
          onPlatformSignIn: () => _handlePlatformSignIn(context),
          onNavigateToSignUp: () =>
              _navigateToSignUp(context, isFromTutorial: false),
        ),
      ),
    );
  }

  Future<void> _navigateToSignUp(BuildContext context,
      {required bool isFromTutorial}) async {
    if (isFromTutorial) {
      await _completeTutorial();
    }
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => RegisterScreen(
          onRegister: (email, password) =>
              _handleRegister(context, email, password),
          onPlatformSignIn: () => _handlePlatformSignIn(context),
          onNavigateToSignIn: () =>
              _navigateToSignIn(context, isFromTutorial: false),
        ),
      ),
    );
  }

  Future<bool> _checkOwnerExists() async {
    await _ownerManager.loadEntities();
    return _ownerManager.entities.isNotEmpty;
  }

  Future<void> _handleInitialOwnerCreation(BuildContext context) async {
    final result = await navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => const InitialOwnerCreationScreen(),
      ),
    );

    if (result is Owner) {
      await _ownerManager.addEntity(result);

      // Ensure questions are cached for first-time users before showing fortune screen
      await FirestoreService.initializeQuestionsCache();

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
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

  Future<void> _handleLogin(
      BuildContext context, String? email, String? password) async {
    if (email == null || password == null) return;
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      _analytics.logLogin(loginMethod: 'email');
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, InfoMessages.loginFailure);
      }
    }
  }

  Future<void> _handleRegister(
      BuildContext context, String? email, String? password) async {
    if (email == null || password == null) return;
    try {
      await _authService.createUserWithEmailAndPassword(email, password);
      _analytics.logSignUp(signUpMethod: 'email');
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, InfoMessages.registerFailure);
      }
    }
  }

  Future<void> _handlePasswordRecovery(
      BuildContext context, String? email) async {
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

  Future<void> _handlePlatformSignIn(BuildContext context) async {
    try {
      UserCredential? userCredential =
          await _authService.handlePlatformSignIn();
      final authMethod = Platform.isIOS ? 'apple' : 'google';

      if (userCredential?.additionalUserInfo?.isNewUser ?? false) {
        _analytics.logSignUp(signUpMethod: authMethod);
      } else {
        _analytics.logLogin(loginMethod: authMethod);
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, InfoMessages.loginFailure);
      }
    }
  }
}
