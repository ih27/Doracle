import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../widgets/form_button.dart';
import '../widgets/input_field.dart';
import 'simple_register_screen.dart';

class SimpleLoginScreen extends StatefulWidget {
  final Function(String? email, String? password)? onLogin;
  final Function(String? email, String? password)? onRegister;
  final Function(String? email)? onPasswordRecovery;
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

  Function(String? email, String? password)? get onLogin => widget.onLogin;
  Function(String? email, String? password)? get onRegister =>
      widget.onRegister;
  Function(String? email)? get onPasswordRecovery => widget.onPasswordRecovery;
  Function()? get onPlatformSignIn => widget.onPlatformSignIn;

  @override
  void initState() {
    super.initState();
    email = '';
    password = '';

    emailError = null;
    passwordError = null;
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Text(
              showPasswordRecovery ? 'Recover Password' : 'Welcome',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              showPasswordRecovery
                  ? 'Enter your email to recover your password.'
                  : 'Sign in to continue!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black.withOpacity(.6),
              ),
            ),
            const SizedBox(height: 30),
            InputField(
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              labelText: 'Email',
              errorText: emailError,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            if (!showPasswordRecovery)
              Column(
                children: [
                  const SizedBox(height: 15),
                  InputField(
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                    onSubmitted: (val) => submit(),
                    labelText: 'Password',
                    errorText: passwordError,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showPasswordRecovery = !showPasswordRecovery;
                  });
                },
                child: Text(
                  showPasswordRecovery ? 'Back to Login' : 'Forgot Password?',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            FormButton(
              text: showPasswordRecovery ? 'Recover' : 'Log In',
              onPressed: submit,
            ),
            if (!showPasswordRecovery)
              Column(
                children: [
                  const SizedBox(height: 15),
                  FormButton(
                    text: Platform.isIOS
                        ? 'Sign in with Apple'
                        : 'Sign in with Google',
                    icon: Image.asset(
                      Platform.isIOS
                          ? 'assets/images/apple_logo.png'
                          : 'assets/images/google_logo.png',
                      height: 24,
                      width: 24,
                    ),
                    onPressed: onPlatformSignIn,
                  ),
                ],
              ),
            const Spacer(flex: 1),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SimpleRegisterScreen(
                    onSubmitted: (email, password) {
                      if (onRegister != null) {
                        onRegister!(email, password);
                        Navigator.pop(
                            context); // Navigate back to login screen after successful registration
                      }
                    },
                  ),
                ),
              ),
              child: RichText(
                text: const TextSpan(
                  text: "I'm a new user, ",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
