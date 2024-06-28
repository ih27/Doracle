import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final Map<String, List<String>> _questionsCache = {};

  static Future<void> initializeQuestionsCache() async {
    final categories = ['Love', 'Finance', 'Health', 'Career', 'Mixed'];

    for (String category in categories) {
      final snapshot = await FirebaseFirestore.instance
          .collection('questions')
          .where('category', isEqualTo: category)
          .limit(500)
          .get();

      final categoryQuestions =
          snapshot.docs.map((doc) => doc['question'] as String).toList();
      _questionsCache[category] = categoryQuestions;
    }
  }

  static List<String> _getRandomQuestionsFromCache(
      int numberOfQuestionsPerCategory) {
    final List<String> randomQuestions = [];

    _questionsCache.forEach((category, questions) {
      final shuffledQuestions = List<String>.from(questions)..shuffle();
      randomQuestions.addAll(
          shuffledQuestions.take(numberOfQuestionsPerCategory).toList());
    });

    randomQuestions.shuffle(); // Shuffle the combined list
    return randomQuestions;
  }

  static Future<List<String>> fetchRandomQuestions(
      int numberOfQuestionsPerCategory) async {
    if (_questionsCache.isEmpty) {
      await initializeQuestionsCache();
    }
    return _getRandomQuestionsFromCache(numberOfQuestionsPerCategory);
  }
}
