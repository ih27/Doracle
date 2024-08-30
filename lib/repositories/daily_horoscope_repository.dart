import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DailyHoroscopeRepository {
  static const String _horoscopeKey = 'daily_horoscope';
  static const String _lastFetchDateKey = 'last_horoscope_fetch_date';
  static const String _ownerHoroscopeKey = 'owner_horoscope';

  Future<void> saveHoroscopeForPet(String petId, String horoscope) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> horoscopes = await loadHoroscopes();
    horoscopes[petId] = horoscope;
    await prefs.setString(_horoscopeKey, json.encode(horoscopes));
    await _updateLastFetchDate();
  }

  Future<void> saveHoroscopeForOwner(String horoscope) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ownerHoroscopeKey, horoscope);
    await _updateLastFetchDate();
  }

  Future<String> loadHoroscopeForPet(String petId) async {
    Map<String, String> horoscopes = await loadHoroscopes();
    return horoscopes[petId] ?? '';
  }

  Future<String> loadHoroscopeForOwner() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ownerHoroscopeKey) ?? '';
  }

  Future<Map<String, String>> loadHoroscopes() async {
    final prefs = await SharedPreferences.getInstance();
    final horoscopesJson = prefs.getString(_horoscopeKey);
    if (horoscopesJson != null) {
      return Map<String, String>.from(json.decode(horoscopesJson));
    }
    return {};
  }

  Future<bool> isHoroscopeStale() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetchDate = prefs.getString(_lastFetchDateKey);
    final currentDate = DateTime.now().toIso8601String().split('T')[0];
    return lastFetchDate != currentDate;
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_horoscopeKey);
    await prefs.remove(_lastFetchDateKey);
    await prefs.remove(_ownerHoroscopeKey);
  }

  Future<void> _updateLastFetchDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _lastFetchDateKey, DateTime.now().toIso8601String().split('T')[0]);
  }
}
