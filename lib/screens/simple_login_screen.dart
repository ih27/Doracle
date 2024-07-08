import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/form_button.dart';
import '../theme.dart';

class SimpleLoginScreen extends StatefulWidget {
  final Function(String?, String?)? onLogin;
  final Function()? onRegister;
  final Function(String?)? onPasswordRecovery;
  final Function()? onPlatformSignIn;

  const SimpleLoginScreen({
    this.onLogin,
    this.onRegister,
    this.onPasswordRecovery,
    this.onPlatformSignIn,
    super.key,
  });

  @override
  State<SimpleLoginScreen> createState() => _SimpleLoginScreenState();
}

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
  late String email, password;
  String? emailError, passwordError;
  bool showPasswordRecovery = false;
  bool _passwordVisibility = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Function(String?, String?)? get onLogin => widget.onLogin;
  Function()? get onRegister => widget.onRegister;
  Function(String?)? get onPasswordRecovery => widget.onPasswordRecovery;
  Function()? get onPlatformSignIn => widget.onPlatformSignIn;

  @override
  void initState() {
    super.initState();
    email = '';
    password = '';
    emailError = null;
    passwordError = null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
        if (onPasswordRecovery != null) {
          onPasswordRecovery!(email);
        }
      } else {
        if (onLogin != null) {
          onLogin!(email, password);
        }
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
              height: 250,
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
                  const SizedBox(height: 32),
                  _buildInputField(
                    controller: _emailController,
                    label: 'Email',
                    onChanged: (value) => email = value,
                    errorText: emailError,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (!showPasswordRecovery) ...[
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _passwordController,
                      label: 'Password',
                      onChanged: (value) => password = value,
                      errorText: passwordError,
                      obscureText: !_passwordVisibility,
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
                  const SizedBox(height: 32),
                  FormButton(
                    text: showPasswordRecovery ? 'Recover' : 'Log In',
                    onPressed: submit,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: onRegister,
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
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Or sign in with',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                          icon: Platform.isIOS
                              ? FontAwesomeIcons.apple
                              : FontAwesomeIcons.google,
                          onPressed: () async {
                            await onPlatformSignIn!();
                          }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
    String? errorText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: label,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: suffixIcon,
      ),
      style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildSocialButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.accent1,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}
