import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'user_repository.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _collectionName = 'users';
  final startingCount = FirestoreService.getStartingCount();

  @override
  Future<void> addUser(String userId, Map<String, dynamic> userData) async {
    userData['createdAt'] = Timestamp.now();
    userData['questionHistory'] = [];
    userData['remainingQuestionsCount'] = startingCount;
    userData['totalQuestionsAsked'] = 0;
    userData['purchaseHistory'] = [];
    await _firestore.collection(_collectionName).doc(userId).set(userData);
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
  Future<void> updateUserFortuneData(
      String userId, String question, String persona) async {
    final userRef = _firestore.collection(_collectionName).doc(userId);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        throw Exception('User does not exist!');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final List<Map<String, dynamic>> questionHistory =
          List<Map<String, dynamic>>.from(userData['questionHistory'] ?? []);
      final int remainingQuestionsCount =
          (userData['remainingQuestionsCount'] ?? 0) - 1;
      final int totalQuestionsAsked =
          (userData['totalQuestionsAsked'] ?? 0) + 1;

      questionHistory.add({
        'question': question,
        'persona': persona,
        'timestamp': Timestamp.now().millisecondsSinceEpoch,
      });

      transaction.update(userRef, {
        'questionHistory': questionHistory,
        'remainingQuestionsCount': remainingQuestionsCount,
        'totalQuestionsAsked': totalQuestionsAsked,
        'lastQuestionTimestamp': FieldValue.serverTimestamp(),
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

  @override
  Future<void> updatePurchaseHistory(String userId, int questionCount) async {
    final userRef = _firestore.collection(_collectionName).doc(userId);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        throw Exception('User does not exist!');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final List<Map<String, dynamic>> purchaseHistory =
          List<Map<String, dynamic>>.from(userData['purchaseHistory'] ?? []);
      final int currentRemainingQuestions =
          userData['remainingQuestionsCount'] ?? 0;

      purchaseHistory.add({
        'questionCount': questionCount,
        'timestamp': Timestamp.now().millisecondsSinceEpoch,
      });

      transaction.update(userRef, {
        'purchaseHistory': purchaseHistory,
        'remainingQuestionsCount': currentRemainingQuestions + questionCount,
      });
    });
  }
}
