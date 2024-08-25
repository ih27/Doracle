import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/compatibility_utils.dart';

class CompatibilityDataRepository {
  static const String _improvementPlansKey = 'improvement_plans';
  static const String _checklistKey = 'improvement_plan_checklist';
  static const String _astrologyKey = 'astrology';
  static const String _recommendationsKey = 'recommendations';
  static const String _cardAvailabilityKey = 'card_availability';
  static const String _lastCompatibilityCheckKey = 'last_compatibility_check';
  static const int maxStoredResults = 10;

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_improvementPlansKey);
    await prefs.remove(_astrologyKey);
    await prefs.remove(_recommendationsKey);
    await prefs.remove(_cardAvailabilityKey);
    await prefs.remove(_lastCompatibilityCheckKey);
  }

  Future<void> saveImprovementPlan(
      String planId, String plan, dynamic entity1, dynamic entity2) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> plans =
        json.decode(prefs.getString(_improvementPlansKey) ?? '{}');

    plans[planId] = {
      'plan': plan,
      'entity1': encodeEntity(entity1),
      'entity2': encodeEntity(entity2),
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (plans.length > maxStoredResults) {
      var sortedKeys = plans.keys.toList(growable: false)
        ..sort((k1, k2) =>
            plans[k2]['timestamp'].compareTo(plans[k1]['timestamp']));
      plans = Map.fromEntries(
          sortedKeys.take(maxStoredResults).map((k) => MapEntry(k, plans[k])));
    }
    await prefs.setString(_improvementPlansKey, json.encode(plans));
  }

  // Load a specific plan
  Future<Map<String, dynamic>> loadImprovementPlan(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> plans =
        json.decode(prefs.getString(_improvementPlansKey) ?? '{}');
    if (plans.containsKey(planId)) {
      var plan = plans[planId];
      return {
        'plan': plan['plan'],
        'entity1': decodeEntity(plan['entity1']),
        'entity2': decodeEntity(plan['entity2']),
        'timestamp': DateTime.parse(plan['timestamp']),
      };
    }
    return {};
  }

  Future<bool> planExists(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> plans =
        json.decode(prefs.getString(_improvementPlansKey) ?? '{}');
    return plans.containsKey(planId);
  }

  // Load all plans
  Future<Map<String, Map<String, dynamic>>> loadImprovementPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final String? plansJson = prefs.getString(_improvementPlansKey);

    if (plansJson != null) {
      Map<String, dynamic> rawPlans = json.decode(plansJson);
      return rawPlans.map((key, value) => MapEntry(key, {
            'plan': value['plan'],
            'entity1': decodeEntity(value['entity1']),
            'entity2': decodeEntity(value['entity2']),
            'timestamp': DateTime.parse(value['timestamp']),
          }));
    }
    return {};
  }

  Future<void> saveChecklistItem(
      String planId, int dayNumber, bool isChecked) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> checklistData =
        json.decode(prefs.getString(_checklistKey) ?? '{}');

    if (!checklistData.containsKey(planId)) {
      checklistData[planId] = {};
    }
    checklistData[planId][dayNumber.toString()] = isChecked;

    await prefs.setString(_checklistKey, json.encode(checklistData));
  }

  Future<Map<int, bool>> loadChecklist(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> checklistData =
        json.decode(prefs.getString(_checklistKey) ?? '{}');

    if (!checklistData.containsKey(planId)) {
      return {};
    }

    return checklistData[planId].map<int, bool>(
        (key, value) => MapEntry(int.parse(key), value as bool));
  }

  Future<void> saveAstrology(String planId, String astrology) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> astrologyData = json
        .decode(prefs.getString(_astrologyKey) ?? '{}')
        .cast<String, String>();
    astrologyData[planId] = astrology;
    await prefs.setString(_astrologyKey, json.encode(astrologyData));
  }

  Future<String?> loadAstrology(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> astrologyData = json
        .decode(prefs.getString(_astrologyKey) ?? '{}')
        .cast<String, String>();
    return astrologyData[planId];
  }

  Future<void> saveRecommendations(
      String planId, String recommendations) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> recommendationsData = json
        .decode(prefs.getString(_recommendationsKey) ?? '{}')
        .cast<String, String>();
    recommendationsData[planId] = recommendations;
    await prefs.setString(
        _recommendationsKey, json.encode(recommendationsData));
  }

  Future<String?> loadRecommendations(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> recommendationsData = json
        .decode(prefs.getString(_recommendationsKey) ?? '{}')
        .cast<String, String>();
    return recommendationsData[planId];
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

  Future<void> saveLastCompatibilityCheck(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _lastCompatibilityCheckKey,
        json.encode({
          'planId': planId,
          'timestamp': DateTime.now().toIso8601String(),
        }));
  }

  Future<String?> loadLastCompatibilityCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final String? checkJson = prefs.getString(_lastCompatibilityCheckKey);
    if (checkJson != null) {
      final Map<String, dynamic> check = json.decode(checkJson);
      return check['planId'] as String?;
    }
    return null;
  }
}
