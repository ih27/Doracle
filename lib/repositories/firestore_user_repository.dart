import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _collectionName = 'users';

  @override
  Future<void> addUser(User user, Map<String, dynamic> userData) async {
    userData['createdAt'] = Timestamp.now();
    userData['questionHistory'] = [];
    userData['questionsAsked'] = 0;
    userData['totalQuestionsAsked'] = 0;
    await _firestore.collection(_collectionName).doc(user.uid).set(userData);
  }

  @override
  Future<Map<String, dynamic>?> getUser(String userId) async {
    DocumentSnapshot userDoc = await _firestore
        .collection(_collectionName)
        .doc(userId)
        .get()
        .timeout(const Duration(seconds: 10));
    return userDoc.data() as Map<String, dynamic>?;
  }

  @override
  Future<void> updateUserFortuneData(String userId, String question) async {
    final userRef = _firestore.collection(_collectionName).doc(userId);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        throw Exception('User does not exist!');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final List<String> questionHistory =
          List<String>.from(userData['questionHistory'] ?? []);
      final int questionsAsked = (userData['questionsAsked'] ?? 0) + 1;
      final int totalQuestionsAsked =
          (userData['totalQuestionsAsked'] ?? 0) + 1;

      questionHistory.add(question);

      transaction.update(userRef, {
        'questionHistory': questionHistory,
        'questionsAsked': questionsAsked,
        'totalQuestionsAsked': totalQuestionsAsked,
      });
    });
  }

  @override
  Future<void> updateUserField<T>(String userId, String field, T value) async {
    await _firestore
        .collection(_collectionName)
        .doc(userId)
        .update({field: value});
  }
}
