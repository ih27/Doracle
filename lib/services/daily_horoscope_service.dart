import 'dart:convert';
import '../config/dependency_injection.dart';
import '../repositories/daily_horoscope_repository.dart';
import 'ai_prompt_generation_service.dart';
import 'openai_service.dart';
import '../models/owner_model.dart';
import '../models/pet_model.dart';

class DailyHoroscopeService {
  final AIPromptGenerationService _aiPromptService = getIt<AIPromptGenerationService>();
  final OpenAIService _openAIService = getIt<OpenAIService>();
  final DailyHoroscopeRepository _repository = getIt<DailyHoroscopeRepository>();

  Future<String> getHoroscopeForPet(Pet pet) async {
    if (await _repository.isHoroscopeStale()) {
      await _repository.clearData();
    }

    String horoscope = await _repository.loadHoroscopeForPet(pet.id);
    if (horoscope.isEmpty) {
      horoscope = await _generateHoroscope(pet: pet);
      await _repository.saveHoroscopeForPet(pet.id, horoscope);
    }
    return horoscope;
  }

  Future<String> getHoroscopeForOwner(Owner owner, List<Pet> pets) async {
    if (await _repository.isHoroscopeStale()) {
      await _repository.clearData();
    }

    String horoscope = await _repository.loadHoroscopeForOwner();
    if (horoscope.isEmpty) {
      horoscope = await _generateHoroscope(owner: owner, pets: pets);
      await _repository.saveHoroscopeForOwner(horoscope);
    }
    return horoscope;
  }

  Future<String> _generateHoroscope({Owner? owner, Pet? pet, List<Pet>? pets}) async {
    String prompt;
    if (owner != null && pets != null) {
      prompt = _aiPromptService.generatePrompt(
        PromptType.dailyHoroscope,
        owner: owner,
        pets: pets,
      );
    } else if (pet != null) {
      prompt = _aiPromptService.generatePrompt(
        PromptType.dailyHoroscope,
        pet: pet,
      );
    } else {
      throw ArgumentError('Invalid horoscope generation request');
    }
    final response = await _openAIService.getDailyHoroscope(prompt);
    String jsonString = response.choices.first.message.content?.first.text ?? '{}';
    return _parseHoroscopeResponse(jsonString);
  }

  String _parseHoroscopeResponse(String response) {
    try {
      Map<String, dynamic> jsonResponse = json.decode(response);
      return jsonResponse['horoscope'] ?? 'No horoscope available';
    } catch (e) {
      return 'Failed to generate horoscope';
    }
  }
}