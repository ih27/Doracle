import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/form_button.dart';
import '../widgets/sendable_textfield.dart';

class RegisterScreen extends StatefulWidget {
  final Function(String?, String?) onRegister;
  final Function() onPlatformSignIn;
  final VoidCallback onNavigateToSignIn;

  const RegisterScreen({
    super.key,
    required this.onRegister,
    required this.onPlatformSignIn,
    required this.onNavigateToSignIn,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late String email, password, confirmPassword;
  String? emailError, passwordError;
  Function(String?, String?) get onRegister => widget.onRegister;
  Function()? get onPlatformSignIn => widget.onPlatformSignIn;
  VoidCallback get onNavigateToSignIn => widget.onNavigateToSignIn;

  bool _passwordVisibility = false;
  bool _confirmPasswordVisibility = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    email = '';
    password = '';
    confirmPassword = '';
    emailError = null;
    passwordError = null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
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

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        passwordError = 'Please enter a password';
      });
      isValid = false;
    }
    if (password != confirmPassword) {
      setState(() {
        passwordError = 'Passwords do not match';
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> submit() async {
    if (validate()) {
      await onRegister(email, password);
    }
  }

  Future<void> _handlePlatformSignIn() async {
    if (onPlatformSignIn != null) {
      await onPlatformSignIn!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(children: [
        // Top image section
        Container(
          height: 300, // Adjust this value as needed
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/background.png'), // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Form content
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign Up',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Become part of the Doracle family!',
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
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
                onChanged: (value) => email = value,
                errorText: emailError,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              SendableTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                labelText: 'Password',
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_confirmPasswordFocus),
                onChanged: (value) => password = value,
                errorText: passwordError,
                obscureText: !_passwordVisibility,
                suffixIcon: _buildVisibilityToggle(_passwordVisibility, () {
                  setState(() => _passwordVisibility = !_passwordVisibility);
                }),
              ),
              const SizedBox(height: 16),
              SendableTextField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocus,
                labelText: 'Confirm Password',
                onSubmitted: (_) => submit(),
                onChanged: (value) => confirmPassword = value,
                errorText: passwordError,
                obscureText: !_confirmPasswordVisibility,
                suffixIcon:
                    _buildVisibilityToggle(_confirmPasswordVisibility, () {
                  setState(() =>
                      _confirmPasswordVisibility = !_confirmPasswordVisibility);
                }),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: FormButton(
                      text: 'Sign Up',
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
                        Platform.isIOS ? Icons.apple : FontAwesomeIcons.google,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: _handlePlatformSignIn,
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
                  onPressed: onNavigateToSignIn,
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'Sign In',
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
        )
      ])),
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
