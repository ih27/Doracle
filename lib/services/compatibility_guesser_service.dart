import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../config/dependency_injection.dart';
import '../models/owner_model.dart';
import '../models/pet_model.dart';
import 'ai_prompt_generation_service.dart';
import 'openai_service.dart';

class CompatibilityGuesser {
  final OpenAIService openAIService;

  final AIPromptGenerationService _aiPromptGenerationService =
      getIt<AIPromptGenerationService>();

  CompatibilityGuesser(this.openAIService);

  // MARK: - Public Methods

  Map<String, dynamic> getPetPetScores(Pet pet1, Pet pet2) {
    // Calculate scores
    double temperamentScore = _calculateTemperamentScore(pet1, pet2);
    double playtimeScore = _calculatePlaytimeScore(pet1, pet2);
    double treatSharingScore = _calculateTreatSharingScore(pet1, pet2);

    // Calculate overall score
    double overallScore =
        (temperamentScore + playtimeScore + treatSharingScore) / 3;

    return {
      'overall': overallScore,
      'temperament': temperamentScore,
      'playtime': playtimeScore,
      'treatSharing': treatSharingScore,
    };
  }

  Map<String, dynamic> getPetOwnerScores(Pet pet, Owner owner) {
    double lifestyleMatchScore = _calculateLifestyleMatchScore(pet, owner);
    double careRequirementsScore = _calculateCareRequirementsScore(pet, owner);
    double temperamentCompatibilityScore =
        _calculateTemperamentCompatibilityScore(pet, owner);

    double overallScore = (lifestyleMatchScore +
            careRequirementsScore +
            temperamentCompatibilityScore) /
        3;

    return {
      'overall': overallScore,
      'temperament': temperamentCompatibilityScore,
      'lifestyle': lifestyleMatchScore,
      'care': careRequirementsScore,
    };
  }

  Future<Map<String, dynamic>> getImprovementPlan(
      dynamic pet, dynamic entity) async {
    String prompt = entity is Owner
        ? _generatePetOwnerPrompt(pet as Pet, entity, PromptType.tenDayPlan)
        : _generatePetPetPrompt(
            pet as Pet, entity as Pet, PromptType.tenDayPlan);
    final response = await openAIService.getCompatibility(prompt);

    debugPrint(response.choices.first.message.content?.first.text);
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
      debugPrint('Error parsing JSON: $e');
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
    debugPrint(jsonString);
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<String?> getAstrologyCompatibility(dynamic pet, dynamic entity) async {
    String prompt = entity is Owner
        ? _generatePetOwnerPrompt(
            pet as Pet, entity, PromptType.astrologicalCompatibility)
        : _generatePetPetPrompt(
            pet as Pet, entity as Pet, PromptType.astrologicalCompatibility);
    final response = await openAIService.getCompatibility(prompt);
    debugPrint(response.choices.first.message.content?.first.text); // DELETE
    return response.choices.first.message.content?.first.text;
  }

  // MARK: - Pet-Pet Compatibility Score Calculations

  double _calculateTemperamentScore(Pet pet1, Pet pet2) {
    // If temperament data is not available, return a neutral score
    if (pet1.temperament.isEmpty || pet2.temperament.isEmpty) {
      return 0.5;
    }

    double totalCompatibility = 0;
    int pairs = 0;

    for (String temp1 in pet1.temperament) {
      for (String temp2 in pet2.temperament) {
        totalCompatibility += _getTemperamentCompatibility(temp1, temp2);
        pairs++;
      }
    }

    return pairs > 0 ? (totalCompatibility / pairs) : 0.5;
  }

  double _getTemperamentCompatibility(String temp1, String temp2) {
    if (temp1 == temp2) return 1.0;
    if (_isComplementary(temp1, temp2)) return 0.8;
    if (_isConflicting(temp1, temp2)) return 0.2;
    return 0.5;
  }

  bool _isComplementary(String temp1, String temp2) {
    Set<String> pair = {temp1, temp2};
    return pair.containsAll({'calm', 'active'}) ||
        pair.containsAll({'shy', 'friendly'}) ||
        pair.containsAll({'aggressive', 'playful'}) ||
        pair.containsAll({'energetic', 'lazy'});
  }

  bool _isConflicting(String temp1, String temp2) {
    Set<String> pair = {temp1, temp2};
    return pair.containsAll({'calm', 'aggressive'}) ||
        pair.containsAll({'calm', 'energetic'}) ||
        pair.containsAll({'active', 'lazy'}) ||
        pair.containsAll({'aggressive', 'friendly'}) ||
        pair.containsAll({'aggressive', 'shy'}) ||
        pair.containsAll({'playful', 'lazy'}) ||
        pair.containsAll({'playful', 'shy'}) ||
        pair.containsAll({'friendly', 'aggressive'}) ||
        pair.containsAll({'shy', 'energetic'}) ||
        pair.containsAll({'energetic', 'lazy'});
  }

  double _calculatePlaytimeScore(Pet pet1, Pet pet2) {
    double exerciseCompatibility =
        1 - (((pet1.exerciseRequirement - pet2.exerciseRequirement).abs()) / 2);
    double socialCompatibility =
        1 - (((pet1.socializationNeed - pet2.socializationNeed).abs()) / 2);

    return (exerciseCompatibility + socialCompatibility) / 2;
  }

  double _calculateTreatSharingScore(Pet pet1, Pet pet2) {
    if (pet1.species == pet2.species) return 1.0;
    if ((pet1.species == 'dog' && pet2.species == 'cat') ||
        (pet1.species == 'cat' && pet2.species == 'dog')) return 0.7;
    if ((pet1.species == 'dog' && pet2.species == 'bird') ||
        (pet1.species == 'bird' && pet2.species == 'dog') ||
        (pet1.species == 'cat' && pet2.species == 'bird') ||
        (pet1.species == 'bird' && pet2.species == 'cat')) return 0.5;
    if (pet1.species == 'fish' || pet2.species == 'fish') return 0.2;
    return 0.5; // Default for any other combination
  }

  // MARK: - Pet-Owner Compatibility Score Calculations

  double _calculateLifestyleMatchScore(Pet pet, Owner owner) {
    double exerciseCompatibility =
        _getExerciseCompatibility(pet.exerciseRequirement, owner.activityLevel);
    double socialCompatibility =
        _getSocialCompatibility(pet.socializationNeed, owner.interactionLevel);
    double livingSituationCompatibility =
        _getLivingSituationCompatibility(pet.species, owner.livingSituation);

    return (exerciseCompatibility +
            socialCompatibility +
            livingSituationCompatibility) /
        3;
  }

  double _getExerciseCompatibility(int petRequirement, int ownerActivity) {
    int difference = (petRequirement - ownerActivity).abs();
    if (difference == 0) return 1.0;
    if (difference == 1) return 0.5;
    return 0.0;
  }

  double _getSocialCompatibility(int petNeed, int ownerInteraction) {
    int difference = (petNeed - ownerInteraction).abs();
    if (difference == 0) return 1.0;
    if (difference == 1) return 0.5;
    return 0.0;
  }

  double _getLivingSituationCompatibility(
      String petSpecies, String? ownerLivingSituation) {
    if (petSpecies == 'bird' || petSpecies == 'fish') return 1.0;

    switch (ownerLivingSituation) {
      case 'House with yard':
      case 'Villa':
        return 1.0;
      case 'Apartment':
        return 0.5;
      default:
        return 0.75;
    }
  }

  double _calculateCareRequirementsScore(Pet pet, Owner owner) {
    double scheduleCompatibility =
        _getScheduleCompatibility(owner.workSchedule);
    double experienceCompatibility =
        _getExperienceCompatibility(owner.petExperience);
    double groomingCompatibility =
        _getGroomingCompatibility(pet.species, owner.groomingCommitment);

    return (scheduleCompatibility +
            experienceCompatibility +
            groomingCompatibility) /
        3;
  }

  double _getExperienceCompatibility(String? petExperience) {
    switch (petExperience) {
      case 'Expert':
        return 1.0;
      case 'Some experience':
        return 0.75;
      case 'First-time':
        return 0.5;
      default:
        return 0.5;
    }
  }

  double _getGroomingCompatibility(
      String petSpecies, int ownerGroomingCommitment) {
    int petGroomingNeeds = _getPetGroomingNeeds(petSpecies);
    if (petGroomingNeeds <= ownerGroomingCommitment) return 1.0;
    if (petGroomingNeeds - ownerGroomingCommitment == 1) return 0.75;
    return 0.5;
  }

  double _getScheduleCompatibility(String? workSchedule) {
    switch (workSchedule) {
      case 'Work from home':
        return 1.0;
      case 'Part-time away':
        return 0.75;
      case 'Full-time away':
        return 0.5;
      default:
        return 0.5;
    }
  }

  int _getPetGroomingNeeds(String petSpecies) {
    switch (petSpecies.toLowerCase()) {
      case 'dog':
        return 3; // Extensive
      case 'cat':
        return 2; // Normal
      default:
        return 1; // Minimal
    }
  }

  double _calculateTemperamentCompatibilityScore(Pet pet, Owner owner) {
    double noiseCompatibility =
        _getNoiseCompatibility(pet.temperament, owner.noiseTolerance);
    double purposeCompatibility =
        _getPurposeCompatibility(pet.temperament, owner.petReason);

    return (noiseCompatibility + purposeCompatibility) / 2;
  }

  double _getNoiseCompatibility(
      List<String> petTemperament, int ownerNoiseTolerance) {
    if ((petTemperament.contains('calm') || petTemperament.contains('shy')) &&
        ownerNoiseTolerance == 1) {
      return 1.0;
    }
    if ((petTemperament.contains('active') ||
            petTemperament.contains('playful')) &&
        ownerNoiseTolerance == 2) {
      return 1.0;
    }
    if (petTemperament.contains('energetic') && ownerNoiseTolerance == 3) {
      return 1.0;
    }
    return 0.5;
  }

  double _getPurposeCompatibility(
      List<String> petTemperament, String? ownerPetReason) {
    switch (ownerPetReason) {
      case 'Companionship':
        return petTemperament.contains('friendly') ||
                petTemperament.contains('playful')
            ? 1.0
            : 0.75;
      case 'Protection':
        return petTemperament.contains('active') ||
                petTemperament.contains('aggressive')
            ? 1.0
            : 0.75;
      case 'Exercise motivation':
        return petTemperament.contains('energetic') ||
                petTemperament.contains('active')
            ? 1.0
            : 0.75;
      default:
        return 0.75;
    }
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
