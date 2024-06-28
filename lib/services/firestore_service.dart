import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static Future<List<String>> fetchRandomQuestions(
      int numberOfQuestions) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('questions')
        .limit(500)
        .get();
    final allQuestions =
        snapshot.docs.map((doc) => doc['question'] as String).toList();
    allQuestions.shuffle();
    return allQuestions.take(numberOfQuestions).toList();
  }
}
