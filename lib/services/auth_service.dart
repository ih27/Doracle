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

  Future<void> _associateEmailWith(UserCredential userCredential) async {
    if (userCredential.additionalUserInfo?.isNewUser ?? false) {
      await _createUserCallback(userCredential.user!.uid, {
        'email': userCredential.user?.email,
      });
    }
  }
}
