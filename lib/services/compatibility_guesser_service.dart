import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import 'openai_service.dart';

class CompatibilityGuesser {
  final OpenAIService openAIService;

  CompatibilityGuesser(this.openAIService);

  Future<Map<String, dynamic>> getPetCompatibility(Pet pet1, Pet pet2) async {
    // Calculate scores
    double temperamentScore = _calculateTemperamentScore(pet1, pet2);
    double playtimeScore = _calculatePlaytimeScore(pet1, pet2);
    double treatSharingScore = _calculateTreatSharingScore(pet1, pet2);

    // Calculate overall score
    double overallScore =
        (temperamentScore + playtimeScore + treatSharingScore) / 3;

    // Generate other compatibility information using OpenAI
    // String prompt = _generatePetPrompt(pet1, pet2, overallScore);

    String prompt = _generatePrompt(pet1, pet2);
    final response = await openAIService.getCompatibility(prompt);

    // Parse the response and extract additional information
    // Map<String, dynamic> additionalInfo = _parseOpenAIResponse(response);

    return {
      'overall': overallScore,
      'temperament': temperamentScore,
      'playtime': playtimeScore,
      'treatSharing': treatSharingScore,
      //...additionalInfo,
    };
  }

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
    // If exercise or socialization data is not available, return a neutral score
    if (pet1.exerciseRequirement == 0 ||
        pet2.exerciseRequirement == 0 ||
        pet1.socializationNeed == 0 ||
        pet2.socializationNeed == 0) {
      return 0.5;
    }

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

  String _generatePetPrompt(Pet pet1, Pet pet2, double overallScore) {
    return '''
    Generate a compatibility analysis for two pets:
    Pet 1: ${pet1.name} (${pet1.species})
    Pet 2: ${pet2.name} (${pet2.species})
    Overall Compatibility Score: ${(overallScore * 100).toStringAsFixed(2)}%

    Please provide:
    1. A short astrological compatibility statement (2-3 sentences)
    2. 3-5 personalized recommendations for improving their relationship
    3. A 7-day compatibility improvement plan with daily activities

    Keep the tone light and fun, suitable for a fortune-telling app.
    ''';
  }

  // Map<String, dynamic> _parseOpenAIResponse(
  //     OpenAIChatCompletionModel response) {
  //   // This is a placeholder implementation. You'll need to parse the actual response
  //   // based on the structure of the OpenAI output.
  //   String content = response.choices.first.message.content ?? '';
  //   List<String> sections = content.split('\n\n');
  //
  //   return {
  //     'astrology': sections.length > 0
  //         ? sections[0]
  //         : 'Astrological compatibility not available.',
  //     'recommendations':
  //         sections.length > 1 ? sections[1] : 'Recommendations not available.',
  //     'improvementPlan':
  //         sections.length > 2 ? sections[2] : 'Improvement plan not available.',
  //   };
  // }

  Future<Map<String, dynamic>> getCompatibility(
      dynamic entity1, dynamic entity2) async {
    String prompt = _generatePrompt(entity1, entity2);
    final response = await openAIService.getCompatibility(prompt);

    // Parse the response and extract compatibility scores
    // This is a placeholder implementation
    return {
      'overall': 0.95,
      'temperament': 0.7,
      'exercise': 0.45,
      'care': 0.25,
    };
  }

  String _generatePrompt(dynamic entity1, dynamic entity2) {
    // Generate a prompt based on the entities' attributes
    // This is a placeholder implementation
    debugPrint("Entities: ${entity1.get('name')} and ${entity2.get('name')}");
    return "someting";
  }
}
