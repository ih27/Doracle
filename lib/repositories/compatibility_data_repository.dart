import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CompatibilityDataRepository {
  static const String _improvementPlanKey = 'improvement_plan';
  static const String _astrologyKey = 'astrology';
  static const String _recommendationsKey = 'recommendations';
  static const String _cardAvailabilityKey = 'card_availability';
  static const String _lastCompatibilityCheckKey = 'last_compatibility_check';

  Future<void> saveImprovementPlan(String plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_improvementPlanKey, plan);
  }

  Future<Map<String, dynamic>?> loadImprovementPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final String? planJson = prefs.getString(_improvementPlanKey);
    if (planJson != null) {
      return json.decode(planJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> saveAstrology(Map<String, dynamic> astrology) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_astrologyKey, json.encode(astrology));
  }

  Future<Map<String, dynamic>?> loadAstrology() async {
    final prefs = await SharedPreferences.getInstance();
    final String? astrologyJson = prefs.getString(_astrologyKey);
    if (astrologyJson != null) {
      return json.decode(astrologyJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> saveRecommendations(Map<String, dynamic> recommendations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recommendationsKey, json.encode(recommendations));
  }

  Future<Map<String, dynamic>?> loadRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recommendationsJson = prefs.getString(_recommendationsKey);
    if (recommendationsJson != null) {
      return json.decode(recommendationsJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> saveCardAvailability(Map<String, bool> availability) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardAvailabilityKey, json.encode(availability));
  }

  Future<Map<String, bool>> loadCardAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    final String? availabilityJson = prefs.getString(_cardAvailabilityKey);
    if (availabilityJson != null) {
      Map<String, dynamic> decoded = json.decode(availabilityJson);
      return decoded.map((key, value) => MapEntry(key, value as bool));
    }
    return {};
  }

  Future<void> saveLastCompatibilityCheck(String entity1Id, String entity2Id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCompatibilityCheckKey, json.encode({
      'entity1': entity1Id,
      'entity2': entity2Id,
      'timestamp': DateTime.now().toIso8601String(),
    }));
  }

  Future<Map<String, dynamic>?> loadLastCompatibilityCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final String? checkJson = prefs.getString(_lastCompatibilityCheckKey);
    if (checkJson != null) {
      return json.decode(checkJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_improvementPlanKey);
    await prefs.remove(_astrologyKey);
    await prefs.remove(_recommendationsKey);
    await prefs.remove(_cardAvailabilityKey);
    await prefs.remove(_lastCompatibilityCheckKey);
  }
}