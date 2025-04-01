import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/form_button.dart';
import '../widgets/sendable_textfield.dart';
import '../config/dependency_injection.dart';
import '../services/unified_analytics_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(String?, String?) onLogin;
  final Function(String?) onPasswordRecovery;
  final VoidCallback onNavigateToSignUp;
  final Function() onPlatformSignIn;

  const LoginScreen({
    required this.onLogin,
    required this.onPasswordRecovery,
    required this.onNavigateToSignUp,
    required this.onPlatformSignIn,
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String email, password;
  String? emailError, passwordError;
  bool showPasswordRecovery = false;
  bool _passwordVisibility = false;
  final UnifiedAnalyticsService _analytics = getIt<UnifiedAnalyticsService>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  Function(String?, String?) get onLogin => widget.onLogin;
  Function(String?) get onPasswordRecovery => widget.onPasswordRecovery;
  VoidCallback get onNavigateToSignUp => widget.onNavigateToSignUp;
  Function() get onPlatformSignIn => widget.onPlatformSignIn;

  @override
  void initState() {
    super.initState();
    email = '';
    password = '';
    emailError = null;
    passwordError = null;

    // Log screen view
    _analytics.logScreenView(screenName: 'login_screen');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void resetErrorText() {
    setState(() {
      emailError = null;
      passwordError = null;
    });
  }

  bool validate() {
    resetErrorText();
    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    bool isValid = true;
    if (email.isEmpty || !emailExp.hasMatch(email)) {
      setState(() {
        emailError = 'Email is invalid';
      });
      isValid = false;
    }

    if (!showPasswordRecovery && password.isEmpty) {
      setState(() {
        passwordError = 'Please enter a password';
      });
      isValid = false;
    }

    return isValid;
  }

  void submit() {
    if (validate()) {
      if (showPasswordRecovery) {
        onPasswordRecovery(email);
      } else {
        onLogin(email, password);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showPasswordRecovery ? 'Recover Password' : 'Sign In',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    showPasswordRecovery
                        ? 'Enter your email to recover your password.'
                        : 'Back for more insights?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          letterSpacing: 0,
                          color: Colors.black54,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SendableTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    labelText: 'Email',
                    onSubmitted: (_) => showPasswordRecovery
                        ? onPasswordRecovery(_emailController.text)
                        : FocusScope.of(context).requestFocus(_passwordFocus),
                    onChanged: (value) => email = value,
                    errorText: emailError,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (!showPasswordRecovery) ...[
                    const SizedBox(height: 16),
                    SendableTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      labelText: 'Password',
                      obscureText: !_passwordVisibility,
                      onSubmitted: (_) => submit(),
                      onChanged: (value) => password = value,
                      errorText: passwordError,
                      suffixIcon:
                          _buildVisibilityToggle(_passwordVisibility, () {
                        setState(
                            () => _passwordVisibility = !_passwordVisibility);
                      }),
                    ),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          showPasswordRecovery = !showPasswordRecovery;
                        });
                      },
                      child: Text(
                        showPasswordRecovery
                            ? 'Back to Sign In'
                            : 'Forgot Password?',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        child: FormButton(
                          text: showPasswordRecovery ? 'Recover' : 'Log In',
                          onPressed: submit,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Theme.of(context).primaryColor, width: 2),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Platform.isIOS
                                ? Icons.apple
                                : FontAwesomeIcons.google,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: onPlatformSignIn,
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: onNavigateToSignUp,
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: Colors.black54),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityToggle(bool isVisible, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: onTap,
    );
  }
}
