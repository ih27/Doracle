import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fortuntella/repositories/user_repository.dart';
import 'package:fortuntella/repositories/firestore_user_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserRepository userRepository = FirestoreUserRepository();
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (user != null) {
        userData = await userRepository.getUser(user!.uid);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to fetch user data. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchUserData,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : errorMessage != null
                      ? Column(
                          children: [
                            Text(errorMessage!),
                            const SizedBox(height: 16),
                            const Text(
                              'Pull down to retry',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Text(
                              'Welcome, ${userData!['email']}',
                              style: const TextStyle(fontSize: 24),
                            )
                          ],
                        ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
