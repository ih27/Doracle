import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Function(String, Map<String, dynamic>) _createUserCallback;

  AuthService(this._createUserCallback);

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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
    final appleProvider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    final userCredential = await _auth.signInWithProvider(appleProvider);
    await _associateEmailWith(userCredential);
    return userCredential;
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
          await _reauthenticateWithApple();
          break;
        default:
          throw Exception('Unsupported provider: $provider');
      }

      await currentUser!.delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _reauthenticateWithApple() async {
    final appleProvider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    await currentUser!.reauthenticateWithProvider(appleProvider);
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
      rethrow;
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
      await _createUserCallback(userCredential.user!.uid, {
        'email': userCredential.user?.email,
      });
    }
  }
}

// CUSTOM AUTH RELATED EXCEPTION
class NeedsReauthenticationException implements Exception {
  final String provider;
  NeedsReauthenticationException(this.provider);
}

class NeedsPasswordReauthenticationException implements Exception {}
