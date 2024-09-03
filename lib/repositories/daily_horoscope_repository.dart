import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DailyHoroscopeRepository {
  static const String _petHoroscopeKey = 'pet_horoscope';
  static const String _ownerHoroscopeKey = 'owner_horoscope';
  static const String _lastPetFetchDateKey = 'last_pet_horoscope_fetch_date';
  static const String _lastOwnerFetchDateKey =
      'last_owner_horoscope_fetch_date';

  Future<void> saveHoroscopeForPet(String petId, String horoscope) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> horoscopes = await loadPetHoroscopes();
    horoscopes[petId] = horoscope;
    await prefs.setString(_petHoroscopeKey, json.encode(horoscopes));
    await _updateLastPetFetchDate();
  }

  Future<void> saveHoroscopeForOwner(String horoscope) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ownerHoroscopeKey, horoscope);
    await _updateLastOwnerFetchDate();
  }

  Future<String> loadHoroscopeForPet(String petId) async {
    Map<String, String> horoscopes = await loadPetHoroscopes();
    return horoscopes[petId] ?? '';
  }

  Future<String> loadHoroscopeForOwner() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ownerHoroscopeKey) ?? '';
  }

  Future<Map<String, String>> loadPetHoroscopes() async {
    final prefs = await SharedPreferences.getInstance();
    final horoscopesJson = prefs.getString(_petHoroscopeKey);
    if (horoscopesJson != null) {
      return Map<String, String>.from(json.decode(horoscopesJson));
    }
    return {};
  }

  Future<bool> isPetHoroscopeStale() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetchDate = prefs.getString(_lastPetFetchDateKey);
    final currentDate = DateTime.now().toIso8601String().split('T')[0];
    return lastFetchDate != currentDate;
  }

  Future<bool> isOwnerHoroscopeStale() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetchDate = prefs.getString(_lastOwnerFetchDateKey);
    final currentDate = DateTime.now().toIso8601String().split('T')[0];
    return lastFetchDate != currentDate;
  }

  Future<void> clearPetHoroscopes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_petHoroscopeKey);
    await prefs.remove(_lastPetFetchDateKey);
  }

  Future<void> clearOwnerHoroscope() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ownerHoroscopeKey);
    await prefs.remove(_lastOwnerFetchDateKey);
  }

  Future<void> _updateLastPetFetchDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _lastPetFetchDateKey, DateTime.now().toIso8601String().split('T')[0]);
  }

  Future<void> _updateLastOwnerFetchDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _lastOwnerFetchDateKey, DateTime.now().toIso8601String().split('T')[0]);
  }
}
