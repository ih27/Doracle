import 'dart:convert';
import 'dart:math' show Random;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/constants.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Map<String, List<String>> _questionsCache = {};
  static final Map<String, String> _personasCache = {};
  static String? _lastUsedPersona;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);
  static const int defaultStartingCount = 50;

  static const String _questionsKey = 'cached_questions';
  static const String _lastFetchTimeKey = 'last_fetch_time';
  static const Duration _cacheDuration = Duration(days: 30);

  static Future<int> getStartingCount() async {
    try {
      final statsDoc =
          await _firestore.collection('questions').doc('stats').get();
      if (statsDoc.exists) {
        return statsDoc.data()?['startingCount'] ?? defaultStartingCount;
      }
    } catch (e) {
      return defaultStartingCount;
    }
    return defaultStartingCount;
  }

  static Future<void> initializeQuestionsCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final lastFetchTime = DateTime.fromMillisecondsSinceEpoch(
          prefs.getInt(_lastFetchTimeKey) ?? 0);

      if (now.difference(lastFetchTime) > _cacheDuration) {
        await _fetchAndCacheQuestions();
        await prefs.setInt(_lastFetchTimeKey, now.millisecondsSinceEpoch);
      } else {
        _questionsCache.clear();
        final cachedQuestions = prefs.getString(_questionsKey);
        if (cachedQuestions != null) {
          final decodedQuestions =
              json.decode(cachedQuestions) as Map<String, dynamic>;
          decodedQuestions.forEach((key, value) {
            _questionsCache[key] = List<String>.from(value);
          });
        }
      }
    } catch (e) {
      _questionsCache.clear();
    }
  }

  static Future<void> _fetchAndCacheQuestions() async {
    final categories = ['Love', 'Finance', 'Health', 'Career', 'Mixed'];
    _questionsCache.clear();

    for (String category in categories) {
      try {
        final snapshot = await _firestore
            .collection('questions')
            .where('category', isEqualTo: category)
            .limit(500)
            .get();

        final categoryQuestions =
            snapshot.docs.map((doc) => doc['question'] as String).toList();
        _questionsCache[category] = categoryQuestions;
      } catch (e) {
        // If fetching fails for a category, add an empty list
        _questionsCache[category] = [];
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_questionsKey, json.encode(_questionsCache));
    } catch (e) {
      // The questions are still in memory, so the app can continue to function
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

    randomQuestions.shuffle();
    return randomQuestions;
  }

  static Future<List<String>> fetchRandomQuestions(
      int numberOfQuestionsPerCategory) async {
    try {
      if (_questionsCache.isEmpty) {
        await initializeQuestionsCache();
      }
      return _getRandomQuestionsFromCache(numberOfQuestionsPerCategory);
    } catch (e) {
      return [];
    }
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
        return {};
      } catch (e) {
        if (attempt == _maxRetries - 1) {
          return _getDefaultPersonas();
        }
        await Future.delayed(_retryDelay);
      }
    }
    return _personasCache;
  }

  static Future<Map<String, String>> getRandomPersona() async {
    if (_personasCache.isEmpty) {
      await fetchPersonas();
    }
    if (_personasCache.isEmpty) {
      return {'name': 'Default', 'instructions': DefaultPersona.instructions};
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
    return {
      'name': selectedPersona,
      'instructions': _personasCache[selectedPersona]!,
    };
  }

  static Map<String, String> _getDefaultPersonas() {
    return {
      'Default': DefaultPersona.instructions,
    };
  }

  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_questionsKey);
      await prefs.remove(_lastFetchTimeKey);
      _questionsCache.clear();
    } catch (e) {
      _questionsCache.clear();
    }
  }
}
