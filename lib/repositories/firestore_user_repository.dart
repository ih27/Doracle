import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addUser(User user, Map<String, dynamic> userData) async {
    userData['createdAt'] = Timestamp.now();
    await _firestore.collection('users').doc(user.uid).set(userData);
  }

  @override
  Future<Map<String, dynamic>?> getUser(String userId) async {
    DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(userId)
        .get()
        .timeout(const Duration(seconds: 10));
    return userDoc.data() as Map<String, dynamic>?;
  }
}
