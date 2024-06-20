import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool passwordVisible = true;

  void _login() async {
    // Validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Email and password cannot be empty');
      return;
    }
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Navigate to home screen
    } on FirebaseAuthException catch (e) {
      // Handle error
      _showErrorDialog(e.message ?? 'An error occurred');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController resetEmailController = TextEditingController();
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: resetEmailController,
            decoration: const InputDecoration(labelText: 'Enter your email'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Validation
                if (resetEmailController.text.isEmpty) {
                  _showErrorDialog('Email cannot be empty');
                  return;
                }
                _resetPassword(resetEmailController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        print('Password reset email sent');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email')),
            TextField(
              controller: _passwordController,
              obscureText: passwordVisible,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                labelText: 'Password', 
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
              ),
            ),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            TextButton(
              onPressed: _navigateToSignUp,
              child: const Text('Don\'t have an account? Sign Up'),
            ),
            TextButton(
              onPressed: _showPasswordResetDialog,
              child: const Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}
