import 'dart:convert';
import '../config/dependency_injection.dart';
import '../repositories/daily_horoscope_repository.dart';
import 'ai_prompt_generation_service.dart';
import 'openai_service.dart';
import '../models/owner_model.dart';
import '../models/pet_model.dart';

class DailyHoroscopeService {
  final AIPromptGenerationService _aiPromptService =
      getIt<AIPromptGenerationService>();
  final OpenAIService _openAIService = getIt<OpenAIService>();
  final DailyHoroscopeRepository _repository =
      getIt<DailyHoroscopeRepository>();

  // METHOD FOR DENUGGING PURPOSES
  Future<void> clearData() async {
    await _repository.clearOwnerHoroscope();
    await _repository.clearPetHoroscopes();
  }

  Future<Map<String, dynamic>> getHoroscopeForPet(Pet pet) async {
    if (await _repository.isPetHoroscopeStale()) {
      await _repository.clearPetHoroscopes();
    }

    String horoscope = await _repository.loadHoroscopeForPet(pet.id);
    if (horoscope.isEmpty) {
      horoscope = await _generateHoroscope(pet: pet);
      await _repository.saveHoroscopeForPet(pet.id, horoscope);
    }
    return json.decode(horoscope);
  }

  Future<Map<String, dynamic>> getHoroscopeForOwner(Owner owner) async {
    if (await _repository.isOwnerHoroscopeStale()) {
      await _repository.clearOwnerHoroscope();
    }

    String horoscope = await _repository.loadHoroscopeForOwner();
    if (horoscope.isEmpty) {
      horoscope = await _generateHoroscope(owner: owner);
      await _repository.saveHoroscopeForOwner(horoscope);
    }
    return json.decode(horoscope);
  }

  Future<String> _generateHoroscope({
    Owner? owner,
    Pet? pet,
  }) async {
    String prompt;
    PromptType promptType;

    if (owner != null) {
      promptType = PromptType.dailyOwnerHoroscope;
      prompt = _aiPromptService.generatePrompt(
        promptType,
        owner: owner,
      );
    } else if (pet != null) {
      promptType = PromptType.dailyPetHoroscope;
      prompt = _aiPromptService.generatePrompt(
        promptType,
        pet: pet,
      );
    } else {
      throw ArgumentError('Invalid horoscope generation request');
    }

    final response = await _openAIService.getDailyHoroscope(prompt);
    String jsonString =
        response.choices.first.message.content?.first.text ?? '{}';
    return jsonString;
  }
}
