import 'package:flutter/material.dart';
import 'package:fortuntella/widgets/form_button.dart';
import 'package:fortuntella/widgets/input_field.dart';
import 'simple_register_screen.dart';

class SimpleLoginScreen extends StatefulWidget {
  final Function(String? email, String? password)? onLogin;
  final Function(String? email, String? password)? onRegister;
  final Function(String? email)? onPasswordRecovery;
  final Function()? onGoogleSignIn;

  const SimpleLoginScreen({
    this.onLogin,
    this.onRegister,
    this.onPasswordRecovery,
    this.onGoogleSignIn,
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
  Function(String? email, String? password)? get onRegister => widget.onRegister;
  Function(String? email)? get onPasswordRecovery => widget.onPasswordRecovery;
  Function()? get onGoogleSignIn => widget.onGoogleSignIn;

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
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            SizedBox(height: screenHeight * .12),
            Text(
              showPasswordRecovery ? 'Recover Password' : 'Welcome',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * .01),
            Text(
              showPasswordRecovery
                  ? 'Enter your email to recover your password.'
                  : 'Sign in to continue!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black.withOpacity(.6),
              ),
            ),
            SizedBox(height: screenHeight * .12),
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
              autoFocus: true,
            ),
            if (!showPasswordRecovery)
              Column(
                children: [
                  SizedBox(height: screenHeight * .025),
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
            SizedBox(
              height: screenHeight * .075,
            ),
            FormButton(
              text: showPasswordRecovery ? 'Recover' : 'Log In',
              onPressed: submit,
            ),
            if (!showPasswordRecovery)
              Column(
                children: [
                  SizedBox(height: screenHeight * .075),
                  ElevatedButton.icon(
                    icon: Image.asset(
                      'assets/google_logo.png', // Ensure you have this asset in your assets folder
                      height: 24,
                      width: 24,
                    ),
                    label: const Text('Sign in with Google'),
                    onPressed: onGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  SizedBox(height: screenHeight * .15),
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
                ],
              ),
          ],
        ),
      ),
    );
  }
}
