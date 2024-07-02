import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/constants.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Map<String, List<String>> _questionsCache = {};
  static final Map<String, String> _personasCache = {};
  static String? _lastUsedPersona;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  static Future<void> initializeQuestionsCache() async {
    final categories = ['Love', 'Finance', 'Health', 'Career', 'Mixed'];

    for (String category in categories) {
      final snapshot = await _firestore
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

  static Future<Map<String, String>> fetchPersonas() async {
    if (_personasCache.isNotEmpty) {
      return _personasCache;
    }

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final snapshot = await _firestore.collection('personas').get();
        for (var doc in snapshot.docs) {
          _personasCache[doc.id] = doc['instructions'] as String;
        }
        if (_personasCache.isNotEmpty) {
          return _personasCache;
        }
        // If we get here, the collection was empty
        throw Exception('Personas collection is empty');
      } catch (e) {
        if (attempt == _maxRetries - 1) {
          // On last attempt, fall back to default personas
          return _getDefaultPersonas();
        }
        await Future.delayed(_retryDelay);
      }
    }
    return _personasCache; // This line should never be reached due to the fallback, but Dart requires it
  }

  static Future<String> getRandomPersonaInstruction() async {
    if (_personasCache.isEmpty) {
      await fetchPersonas();
    }
    if (_personasCache.isEmpty) {
      // This should never happen due to the fallback in fetchPersonas, but just in case:
      return DefaultPersona.instructions;
    }

    List<String> availablePersonas = _personasCache.keys.toList();
    if (_lastUsedPersona != null) {
      availablePersonas.remove(_lastUsedPersona);
    }
    if (availablePersonas.isEmpty) {
      availablePersonas = _personasCache.keys.toList();
    }
    final random = Random().nextInt(availablePersonas.length);
    final selectedPersona = availablePersonas[random];
    _lastUsedPersona = selectedPersona;
    return _personasCache[selectedPersona]!;
  }

  static Map<String, String> _getDefaultPersonas() {
    return {
      'default': DefaultPersona.instructions,
    };
  }
}
