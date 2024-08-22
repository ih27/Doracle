import '../helpers/string_extensions.dart';
import '../models/pet_model.dart';
import '../models/owner_model.dart';

enum PromptType {
  tenDayPlan,
  astrologicalCompatibility,
  personalizedRecommendations,
}

class AIPromptGenerationService {

  // MARK: - Public prompt generator method

  String generatePrompt(PromptType type, {Pet? pet, Owner? owner, Pet? secondPet}) {
    switch (type) {
      case PromptType.tenDayPlan:
        return _generateTenDayPlanPrompt(pet!, owner!);
      case PromptType.astrologicalCompatibility:
        return _generateAstrologicalCompatibilityPrompt(pet!, owner ?? secondPet!);
      case PromptType.personalizedRecommendations:
        return _generatePersonalizedRecommendationsPrompt(pet!, owner ?? secondPet!);
      default:
        throw ArgumentError('Unsupported prompt type');
    }
  }

  // MARK: - Internal prompt generator methods

  String _generateTenDayPlanPrompt(Pet pet, Owner owner) {
    return '''
Generate a 10-day compatibility improvement plan for a pet and their owner in json.
Use the following information:

Pet Information:
- Name: ${pet.name}
- Type: ${pet.species}
- Temperament: ${pet.temperament.join(', ')}
- Exercise Requirement: ${_getRequirementLevel(pet.exerciseRequirement)}
- Social Needs: ${_getRequirementLevel(pet.socializationNeed)}

Owner Information:
- Name: ${owner.name}
- Living Situation: ${owner.livingSituation ?? 'Unknown'}
- Daily Activity Level: ${_getActivityLevel(owner.activityLevel)}
- Desired Interaction Level: ${_getInteractionLevel(owner.interactionLevel)}
- Work Schedule: ${owner.workSchedule ?? 'Unknown'}
- Pet Experience: ${owner.petExperience ?? 'Unknown'}
- Grooming Commitment: ${_getGroomingCommitment(owner.groomingCommitment)}
- Noise Tolerance: ${_getNoiseToleranceLevel(owner.noiseTolerance)}
- Primary Reason for Pet: ${owner.petReason ?? 'Unknown'}

Create a 10-day plan titled "Pawsitive Progress: 10-Day Bonding Boost for ${pet.name} and ${owner.name}". For each day, provide:

1. Day Number and a catchy title for the day's theme
2. A specific task or activity (1-2 sentences)
3. The purpose or benefit of the activity (1 sentence)
4. A quick tip for success (1 sentence)

The plan should:
1. Address different aspects of pet care and bonding (e.g., exercise, training, grooming, play, relaxation)
2. Be progressive, starting with simpler tasks and building up
3. Take into account the pet's needs and owner's lifestyle
4. Include a mix of quick daily habits and longer, more involved activities
5. Be fun and engaging while also practical and beneficial
6. Incorporate activities that align with the owner's primary reason for having a pet

Preface the plan with a brief, encouraging introduction (2-3 sentences) that motivates the owner to commit to the 10-day journey.

After the 10-day plan, include a short conclusion (2-3 sentences) that encourages continuing the positive habits formed and celebrates the strengthened bond.
''';
  }

  String _generateAstrologicalCompatibilityPrompt(Pet pet, dynamic other) {
    String otherType = other is Owner ? 'their owner' : 'another pet';
    return '''
Generate an astrological compatibility analysis for a pet and $otherType. Use the following information:

Pet Information:
- Name: ${pet.name}
- Type: ${pet.species}
- Birthdate: ${pet.birthdate}
- Birthtime: ${pet.birthtime}
- Location: ${pet.location}

${otherType.capitalize()} Information:
- Name: ${other.name}
- Birthdate: ${other.birthdate}
- Birthtime: ${other.birthtime}
- Location: ${other.location}

Please provide:
1. A brief overview of the astrological compatibility (2-3 sentences)
2. Analysis of Sun sign compatibility (2-3 sentences)
3. Analysis of Moon sign compatibility (2-3 sentences)
4. Analysis of Ascendant (Rising sign) compatibility (2-3 sentences)
5. Any significant planetary aspects between the pet and $otherType charts (2-3 sentences)
6. Overall compatibility score out of 10, with a brief explanation

Keep the tone light, fun, and suitable for a pet-owner relationship, while providing genuine astrological insights.
''';
  }

  String _generatePersonalizedRecommendationsPrompt(Pet pet, dynamic other) {
    String otherType = other is Owner ?  'their owner' : 'another pet';
    return '''
Generate personalized recommendations for improving the relationship between a pet and $otherType. Use the following information:

Pet Information:
- Name: ${pet.name}
- Type: ${pet.species}
- Temperament: ${pet.temperament.join(', ')}
- Exercise Requirement: ${_getRequirementLevel(pet.exerciseRequirement)}
- Social Needs: ${_getRequirementLevel(pet.socializationNeed)}

${otherType.capitalize()} Information:
${other is Owner ? _getOwnerInfo(other) : _getPetInfo(other)}

Please provide:
1. 5-7 personalized recommendations for improving their relationship
2. For each recommendation, include:
   a. A clear, actionable suggestion (1-2 sentences)
   b. The benefit or purpose of the recommendation (1 sentence)
   c. A practical tip for implementing the suggestion (1 sentence)
3. Ensure recommendations address various aspects of their relationship, such as:
   - Communication and understanding
   - Physical and mental stimulation
   - Bonding activities
   - Addressing potential challenges or conflicts
   - Enhancing the $otherType's caretaking skills (if applicable)
   - Improving the pet's behavior or skills (if applicable)

Keep the recommendations positive, encouraging, and tailored to the specific needs and characteristics of both the pet and $otherType.
''';
  }


  // MARK: - Helper methods

  String _getOwnerInfo(Owner owner) {
    return '''
- Name: ${owner.name}
- Living Situation: ${owner.livingSituation}
- Daily Activity Level: ${_getActivityLevel(owner.activityLevel)}
- Desired Interaction Level: ${_getInteractionLevel(owner.interactionLevel)}
- Work Schedule: ${owner.workSchedule}
- Pet Experience: ${owner.petExperience}
- Grooming Commitment: ${_getGroomingCommitment(owner.groomingCommitment)}
- Noise Tolerance: ${_getNoiseToleranceLevel(owner.noiseTolerance)}
- Primary Reason for Pet: ${owner.petReason}
''';
  }

  String _getPetInfo(Pet pet) {
    return '''
- Name: ${pet.name}
- Type: ${pet.species}
- Temperament: ${pet.temperament.join(', ')}
- Exercise Requirement: ${_getRequirementLevel(pet.exerciseRequirement)}
- Social Needs: ${_getRequirementLevel(pet.socializationNeed)}
''';
  }

  String _getRequirementLevel(int level) {
    switch (level) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  String _getActivityLevel(int level) {
    switch (level) {
      case 1:
        return 'Sedentary';
      case 2:
        return 'Low active';
      case 3:
        return 'Active';
      case 4:
        return 'Very active';
      default:
        return 'Unknown';
    }
  }

  String _getInteractionLevel(int level) {
    switch (level) {
      case 1:
        return 'Low';
      case 2:
        return 'Moderate';
      case 3:
        return 'High';
      default:
        return 'Unknown';
    }
  }

  String _getGroomingCommitment(int level) {
    switch (level) {
      case 1:
        return 'Minimal';
      case 2:
        return 'Normal';
      case 3:
        return 'Extensive';
      default:
        return 'Unknown';
    }
  }

  String _getNoiseToleranceLevel(int level) {
    switch (level) {
      case 1:
        return 'Need quiet';
      case 2:
        return 'Moderate noise ok';
      case 3:
        return 'High tolerance';
      default:
        return 'Unknown';
    }
  }
}
