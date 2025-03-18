import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../config/dependency_injection.dart';
import '../services/secure_storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Function(String, Map<String, dynamic>) _createUserCallback;
  final SecureStorageService _secureStorage = getIt<SecureStorageService>();

  // Key for storing Apple user name in secure storage
  static const String _appleNameKey = 'apple_display_name';

  AuthService(this._createUserCallback);

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Store user name in secure storage
  Future<void> storeUserName(String userId, String name) async {
    try {
      final key = '${_appleNameKey}_$userId';
      await _secureStorage.write(key: key, value: name);
    } catch (e) {
      debugPrint('Error storing name in secure storage: $e');
    }
  }

  // Get user's name from secure storage
  Future<String?> getUserName(String userId) async {
    try {
      final key = '${_appleNameKey}_$userId';
      return await _secureStorage.read(key: key);
    } catch (e) {
      debugPrint('Error getting name from secure storage: $e');
      return null;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _createUserCallback(userCredential.user!.uid, {
      'email': email,
    });
    return userCredential;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    await _associateEmailWith(userCredential);
    return userCredential;
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      // Create provider with necessary scopes
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name')
        ..addScope('fullName');

      // Get credentials from Apple
      final userCredential = await _auth.signInWithProvider(appleProvider);

      // Debug log
      debugPrint('Apple Sign In email: ${userCredential.user?.email}');

      // Extract display name using a helper method
      String? displayName = _extractDisplayName(userCredential);

      // Store name if found
      if (displayName != null &&
          displayName.isNotEmpty &&
          userCredential.user != null) {
        _cachedAppleDisplayName = displayName;
        await storeUserName(userCredential.user!.uid, displayName);
      }

      await _associateEmailWith(userCredential);
      return userCredential;
    } catch (e) {
      debugPrint('Error during Apple Sign In: $e');
      rethrow;
    }
  }

  Future<UserCredential?> handlePlatformSignIn() async {
    if (Platform.isAndroid) {
      return await signInWithGoogle();
    } else if (Platform.isIOS) {
      return await signInWithApple();
    }
    throw UnsupportedError('Unsupported platform for sign-in');
  }

  Future<void> signOut() async {
    if (Platform.isAndroid) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  Future<void> deleteUser() async {
    try {
      await currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        final provider = currentUser?.providerData.first.providerId;
        throw NeedsReauthenticationException(provider ?? 'unknown');
      }
      rethrow;
    }
  }

  Future<void> reauthenticateAndDelete(String provider) async {
    try {
      switch (provider) {
        case 'password':
          throw NeedsPasswordReauthenticationException();
        case 'google.com':
          final credential = await _getGoogleCredential();
          if (credential != null) {
            await currentUser!.reauthenticateWithCredential(credential);
          } else {
            throw Exception('Failed to obtain Google credential');
          }
          break;
        case 'apple.com':
          try {
            await _reauthenticateWithApple();
          } catch (e) {
            debugPrint('Apple reauthentication failed in deletion flow: $e');
            rethrow; // Propagate to UI layer for showing in snackbar
          }
          break;
        default:
          throw Exception('Unsupported provider: $provider');
      }

      await currentUser!.delete();
    } catch (e) {
      debugPrint('Account deletion failed: $e');
      rethrow;
    }
  }

  Future<void> _reauthenticateWithApple() async {
    try {
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      await currentUser!.reauthenticateWithProvider(appleProvider);
    } catch (e) {
      debugPrint('Apple reauthentication failed: $e');
      // Rethrow with more descriptive message but don't crash the app
      throw Exception('Failed to re-authenticate with Apple Sign In');
    }
  }

  Future<void> reauthenticateWithPasswordAndDelete(String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.delete();
    } catch (e) {
      debugPrint('Password reauthentication failed: $e');
      throw Exception('Failed to authenticate with password');
    }
  }

  Future<AuthCredential?> _getGoogleCredential() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      return GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    }
    return null;
  }

  Future<void> _associateEmailWith(UserCredential userCredential) async {
    if (userCredential.additionalUserInfo?.isNewUser ?? false) {
      final Map<String, dynamic> userData = {
        'email': userCredential.user?.email,
      };

      await _createUserCallback(userCredential.user!.uid, userData);
    }
  }

  // Add a field to cache the display name
  String? _cachedAppleDisplayName;

  // Helper method to extract display name from user credentials
  String? _extractDisplayName(UserCredential userCredential) {
    // 1. Try Firebase user display name first
    if (userCredential.user?.displayName != null &&
        userCredential.user!.displayName!.isNotEmpty) {
      return userCredential.user!.displayName;
    }

    // 2. Try to extract from profile data
    final profile = userCredential.additionalUserInfo?.profile;
    if (profile == null) return null;

    // Direct name field
    if (profile.containsKey('name') && profile['name'] != null) {
      return profile['name'] as String?;
    }

    // First/last name fields
    final firstName = profile['firstName'] ??
        (profile['name'] is Map ? profile['name']['firstName'] : null);
    final lastName = profile['lastName'] ??
        (profile['name'] is Map ? profile['name']['lastName'] : null);

    if (firstName != null || lastName != null) {
      final nameParts = <String>[];
      if (firstName != null) nameParts.add(firstName.toString());
      if (lastName != null) nameParts.add(lastName.toString());
      return nameParts.isNotEmpty ? nameParts.join(' ') : null;
    }

    return null;
  }

  // Improved method to get name from Apple Sign In
  String? getNameFromCredential() {
    // First check our cache
    if (_cachedAppleDisplayName != null &&
        _cachedAppleDisplayName!.isNotEmpty) {
      return _cachedAppleDisplayName;
    }

    // Then try Firebase Auth's display name
    if (currentUser?.displayName != null &&
        currentUser!.displayName!.isNotEmpty) {
      return currentUser!.displayName;
    }

    // Try to get from provider data
    if (currentUser?.providerData.isNotEmpty == true) {
      for (var info in currentUser!.providerData) {
        if (info.displayName != null && info.displayName!.isNotEmpty) {
          return info.displayName;
        }
      }
    }

    return null;
  }

  // Method to get name, prioritizing secure storage
  Future<String?> getAppleUserName() async {
    if (currentUser == null) return null;

    // First try to get from secure storage
    String? storedName = await getUserName(currentUser!.uid);
    if (storedName != null && storedName.isNotEmpty) {
      return storedName;
    }

    // Fall back to in-memory cache or credential
    return getNameFromCredential();
  }
}

// CUSTOM AUTH RELATED EXCEPTION
class NeedsReauthenticationException implements Exception {
  final String provider;
  NeedsReauthenticationException(this.provider);
}

class NeedsPasswordReauthenticationException implements Exception {}
