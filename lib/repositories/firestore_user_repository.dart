import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Future<void> addUser(String userId, Map<String, dynamic> userData) async {
    await _usersCollection.doc(userId).set(userData);
  }

  @override
  Future<Map<String, dynamic>?> getUser(String userId) async {
    DocumentSnapshot doc = await _usersCollection.doc(userId).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await _usersCollection.doc(userId).update(userData);
  }
}
