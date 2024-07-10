import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/fortune_content_repository.dart';

class QuestionCacheService {
  static const String _questionsKey = 'cached_questions';
  static const String _lastFetchTimeKey = 'last_fetch_time';
  static const Duration _cacheDuration = Duration(days: 30);
  static const int _numberOfQuestionsPerCategory = 3;

  final FortuneContentRepository _fortuneContentRepository;

  QuestionCacheService(this._fortuneContentRepository);

  Future<void> initializeCache() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastFetchTime = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt(_lastFetchTimeKey) ?? 0);

    if (now.difference(lastFetchTime) > _cacheDuration) {
      debugPrint("Cache is expired or doesn't exist, initializing cache");
      await _fetchAndCacheQuestions();
      await prefs.setInt(_lastFetchTimeKey, now.millisecondsSinceEpoch);
    } else {
      debugPrint("Cache is still valid");
    }
  }

  Future<List<String>> getRandomQuestions() async {
    final cachedQuestions = await _getCachedQuestions();
    if (cachedQuestions.isEmpty) {
      debugPrint("Cache is empty, fetching new questions");
      return _fetchAndCacheQuestions();
    }
    return cachedQuestions;
  }

  Future<List<String>> _fetchAndCacheQuestions() async {
    final questions = await _fortuneContentRepository
        .fetchRandomQuestions(_numberOfQuestionsPerCategory);
    await _cacheQuestions(questions);
    return questions;
  }

  Future<void> _cacheQuestions(List<String> questions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_questionsKey, jsonEncode(questions));
  }

  Future<List<String>> _getCachedQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_questionsKey);
    if (cachedData != null) {
      return List<String>.from(jsonDecode(cachedData));
    }
    return [];
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_questionsKey);
    await prefs.remove(_lastFetchTimeKey);
  }
}
