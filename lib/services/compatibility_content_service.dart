import 'dart:async';
import 'dart:convert';
import '../models/owner_model.dart';
import '../models/pet_model.dart';
import 'ai_prompt_generation_service.dart';
import 'openai_service.dart';

class CompatibilityContentService {
  final OpenAIService openAIService;
  final AIPromptGenerationService _aiPromptGenerationService;

  CompatibilityContentService(
      this.openAIService, this._aiPromptGenerationService);

  // MARK: - Public Methods

  Future<Map<String, dynamic>> getImprovementPlan(
      dynamic pet, dynamic entity) async {
    String prompt = entity is Owner
        ? _generatePetOwnerPrompt(pet as Pet, entity, PromptType.tenDayPlan)
        : _generatePetPetPrompt(
            pet as Pet, entity as Pet, PromptType.tenDayPlan);
    final response = await openAIService.getCompatibility(prompt);

    String jsonString =
        response.choices.first.message.content?.first.text ?? '{}';

    try {
      Map<String, dynamic> planMap = json.decode(jsonString);
      // Validate the structure
      if (!_isValidPlanStructure(planMap)) {
        throw const FormatException('Invalid plan structure');
      }
      return planMap;
    } catch (e) {
      // Error parsing JSON
      return {
        'error': 'Failed to parse improvement plan',
        'rawContent': jsonString
      };
    }
  }

  Future<Map<String, dynamic>> getRecommendations(
      dynamic pet, dynamic entity) async {
    String prompt = entity is Owner
        ? _generatePetOwnerPrompt(
            pet as Pet, entity, PromptType.personalizedRecommendations)
        : _generatePetPetPrompt(
            pet as Pet, entity as Pet, PromptType.personalizedRecommendations);
    final response = await openAIService.getCompatibility(prompt);

    // Parse the content as JSON
    final String jsonString =
        response.choices.first.message.content?.first.text ?? '{}';
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<String?> getAstrologyCompatibility(dynamic pet, dynamic entity) async {
    String prompt = entity is Owner
        ? _generatePetOwnerPrompt(
            pet as Pet, entity, PromptType.astrologicalCompatibility)
        : _generatePetPetPrompt(
            pet as Pet, entity as Pet, PromptType.astrologicalCompatibility);
    final response = await openAIService.getCompatibility(prompt);
    return response.choices.first.message.content?.first.text;
  }

  // MARK: - OpenAI Integration
  bool _isValidPlanStructure(Map<String, dynamic> plan) {
    return plan.containsKey('introduction') &&
        plan.containsKey('compatibility_improvement_plan') &&
        plan.containsKey('conclusion') &&
        plan['compatibility_improvement_plan'] is List &&
        (plan['compatibility_improvement_plan'] as List).length == 10 &&
        (plan['compatibility_improvement_plan'] as List).every((day) =>
            day is Map &&
            day.containsKey('day') &&
            day.containsKey('title') &&
            day.containsKey('task') &&
            day.containsKey('benefit') &&
            day.containsKey('tip'));
  }

  String _generatePetOwnerPrompt(Pet pet, Owner owner, PromptType promptType) {
    return _aiPromptGenerationService.generatePrompt(
      promptType,
      pet: pet,
      owner: owner,
    );
  }

  String _generatePetPetPrompt(Pet pet1, Pet pet2, PromptType promptType) {
    return _aiPromptGenerationService.generatePrompt(
      promptType,
      pet: pet1,
      secondPet: pet2,
    );
  }
}
