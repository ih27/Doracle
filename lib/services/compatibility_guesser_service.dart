import 'package:flutter/material.dart';
import 'openai_service.dart';

class CompatibilityGuesser {
  final OpenAIService openAIService;

  CompatibilityGuesser(this.openAIService);

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
      'astrology': 'You\'re very harmonious!',
      'recommendations': 'Spend more time playing together.',
      'improvementPlan': 'Day 1: Go for a long walk together.',
    };
  }

  String _generatePrompt(dynamic entity1, dynamic entity2) {
    // Generate a prompt based on the entities' attributes
    // This is a placeholder implementation
    debugPrint("Entities: ${entity1.get('name')} and ${entity2.get('name')}");
    return "someting";
  }
}
