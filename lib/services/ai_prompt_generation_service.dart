import '../models/pet_model.dart';
import '../models/owner_model.dart';

enum PromptType {
  tenDayPlan,
  astrologicalCompatibility,
  personalizedRecommendations,
}

enum EntityCombination {
  petOwner,
  petPet,
}

class AIPromptGenerationService {

  // MARK: - Public methods

  String generatePrompt(PromptType type, {required Pet pet, Owner? owner, Pet? secondPet}) {
    final combination = owner != null ? EntityCombination.petOwner : EntityCombination.petPet;
    return _generatePromptForType(type, combination, pet: pet, owner: owner, secondPet: secondPet);
  }

  // MARK: - Internal methods

  String _generatePromptForType(PromptType type, EntityCombination combination, {required Pet pet, Owner? owner, Pet? secondPet}) {
    final basePrompt = _getBasePrompt(type, combination);
    final entityInfo = _getEntityInfo(combination, pet: pet, owner: owner, secondPet: secondPet);
    final specificInstructions = _getSpecificInstructions(type, combination);

    return '''
$basePrompt

$entityInfo

$specificInstructions
''';
  }

  String _getBasePrompt(PromptType type, EntityCombination combination) {
    switch (type) {
      case PromptType.tenDayPlan:
        return "Generate a 10-day ${combination == EntityCombination.petOwner ? 'compatibility improvement plan for a pet and their owner' : 'action plan to improve the compatibility and relationship between two pets'} in json.";
      case PromptType.astrologicalCompatibility:
        return "Generate an astrological compatibility analysis for ${combination == EntityCombination.petOwner ? 'a pet and their owner' : 'two pets'}, divided into four specific categories in json.";
      case PromptType.personalizedRecommendations:
        return "Generate fun and practical ${combination == EntityCombination.petOwner ? 'pet care recommendations for a pet and their owner' : 'pet-to-pet compatibility recommendations'} in json.";
    }
  }

  String _getEntityInfo(EntityCombination combination, {required Pet pet, Owner? owner, Pet? secondPet}) {
    String petInfo = _getPetInfo(pet);
    if (combination == EntityCombination.petOwner) {
      return '''
$petInfo

Owner Information:
- Name: ${owner!.name}
- Date of Birth: ${owner.birthdate}
- Time of Birth: ${owner.birthtime ?? 'Unavailable'}
- Living Situation: ${owner.livingSituation ?? 'Unknown'}
- Daily Activity Level: ${_getActivityLevel(owner.activityLevel)}
- Desired Interaction Level: ${_getInteractionLevel(owner.interactionLevel)}
- Work Schedule: ${owner.workSchedule ?? 'Unknown'}
- Pet Experience: ${owner.petExperience ?? 'Unknown'}
- Grooming Commitment: ${_getGroomingCommitment(owner.groomingCommitment)}
- Noise Tolerance: ${_getNoiseToleranceLevel(owner.noiseTolerance)}
- Primary Reason for Pet: ${owner.petReason ?? 'Unknown'}
''';
    } else {
      return '''
$petInfo

Pet B Information:
${_getPetInfo(secondPet!, isPetB: true)}
''';
    }
  }

  String _getPetInfo(Pet pet, {bool isPetB = false}) {
    return '''
${isPetB ? 'Pet B' : 'Pet'} Information:
- Name: ${pet.name}
- Type: ${pet.species}
- Date of Birth: ${pet.birthdate}
- Time of Birth: ${pet.birthtime ?? 'Unavailable'}
- Temperament: ${pet.temperament.join(', ')}
- Exercise Requirement: ${_getRequirementLevel(pet.exerciseRequirement)}
- Social Needs: ${_getRequirementLevel(pet.socializationNeed)}
''';
  }

  String _getSpecificInstructions(PromptType type, EntityCombination combination) {
    switch (type) {
      case PromptType.tenDayPlan:
        return _getTenDayPlanInstructions(combination);
      case PromptType.astrologicalCompatibility:
        return _getAstrologyInstructions(combination);
      case PromptType.personalizedRecommendations:
        return _getRecommendationsInstructions(combination);
    }
  }

  String _getTenDayPlanInstructions(EntityCombination combination) {
    String common = '''
For each day, provide:
1. Day Number and a catchy title for the day's theme
2. A specific task or activity (1-2 sentences)
3. The purpose or benefit of the activity (1 sentence)
4. A quick tip for success (1 sentence)

The plan should:
1. Address different aspects of ${combination == EntityCombination.petOwner ? 'pet care and bonding' : 'compatibility and relationship building'}
2. Be progressive, starting with simpler tasks and building up
3. Take into account the ${combination == EntityCombination.petOwner ? "pet's needs and owner's lifestyle" : "needs and temperaments of both pets"}
4. Include a mix of quick daily habits and longer, more involved activities
5. Be fun and engaging while also practical and beneficial
''';

    if (combination == EntityCombination.petOwner) {
      common += "6. Incorporate activities that align with the owner's primary reason for having a pet\n";
    } else {
      common += '''
6. Consider the potential challenges of the specific pet type combination when designing tasks
7. Incorporate rest days or lower-intensity days to prevent overwhelming the pets
8. Include tasks that involve the pet owners in facilitating positive interactions between the pets
''';
    }

    common += '''
Preface the plan with a brief, encouraging introduction (2-3 sentences) that motivates ${combination == EntityCombination.petOwner ? 'the owner' : 'the pet owners'} to commit to the 10-day journey.

After the 10-day plan, include a short conclusion (2-3 sentences) that encourages continuing the positive habits formed and celebrates the strengthened bond.
''';

    return common;
  }

  String _getAstrologyInstructions(EntityCombination combination) {
    return '''
First, determine the zodiac signs based on the birthdates provided. Then, create content for four cards:

1. Elemental Harmony
Title: [Create a catchy title related to the elements of both signs]
Content: [About 50 words discussing how the elements of their signs interact. Include the determined sun signs.]

2. Planetary Influence
Title: [Create a title mentioning the ruling planets of both signs]
Content: [About 50 words explaining how the planetary rulers influence their relationship. Include the determined sun signs and their ruling planets.]

3. Sun Sign Compatibility
Title: [Create a title highlighting the sun sign pairing]
Content: [About 50 words describing how their sun signs complement or challenge each other. Explicitly state the determined sun signs.]

4. Moon Sign Synergy
Title: [Create a title about emotional connection]
Content: [If birth hours are provided, determine the moon signs and write about 50 words on how their moon signs affect their emotional bond. If birth hours are not available, provide a general statement about emotional compatibility based on sun signs. Mention if this is based on sun or moon signs.]

For each card:
- The title should be catchy and relevant to the content.
- The content should be positive and engaging, highlighting complementary aspects while briefly acknowledging potential challenges.
- Use astrological terminology but keep it accessible to a general audience.
- Tailor the language to describe a ${combination == EntityCombination.petOwner ? 'pet-owner relationship' : 'pet-to-pet relationship'} rather than a human-human relationship.
- Always include the determined zodiac signs in the content for transparency.

The tone should be warm, optimistic, and fun, suitable for an entertainment feature in a pet app. Remember, this is for a ${combination == EntityCombination.petOwner ? 'pet-owner relationship' : 'pet-to-pet relationship'}, so keep the analysis lighthearted and pet-focused.

Preface your response with a brief note stating the zodiac signs you've determined for ${combination == EntityCombination.petOwner ? 'both the pet and the owner' : 'both pets'} based on the provided birthdates. This will help users understand the basis of the analysis.
''';
  }

  String _getRecommendationsInstructions(EntityCombination combination) {
    return '''
Based on this information, create 5 practical recommendations and 1 astrological bonus tip. Each practical recommendation should:
1. Be 2-3 sentences long.
2. Focus on a practical ${combination == EntityCombination.petOwner ? 'pet care tip' : 'tip to improve compatibility between the two pets'} with a fun, engaging twist.
3. Address a specific aspect of the ${combination == EntityCombination.petOwner ? 'pet-owner relationship or care routine' : 'pet-to-pet relationship or shared activities'}.
4. Be actionable and specific to their situation.
5. Take into account ${combination == EntityCombination.petOwner ? "the pet's needs and the owner's lifestyle/preferences" : "both pets' needs, temperaments, and characteristics"}.
6. Include a playful or humorous element to make it more entertaining.

The practical recommendations should cover a range of topics, which may include:
${combination == EntityCombination.petOwner ? '''
- Exercise and play ideas
- Social interaction and bonding activities
- Creative training techniques
- Innovative grooming and care routines
- Clever ways to pet-proof or enhance their living space
- Tips for balancing work and pet care
- Fun solutions to potential challenges based on their compatibility
''' : '''
- Safe introduction techniques
- Shared play and exercise ideas
- Space management and territory solutions
- Behavior training for improved compatibility
- Stress reduction methods
- Creative ways to encourage positive interactions
- Tips for managing different energy levels or social needs
- Fun solutions to potential challenges based on their compatibility
'''}

For the astrological bonus tip:
1. Create a separate recommendation based on the zodiac signs of ${combination == EntityCombination.petOwner ? 'the pet and owner' : 'both pets'}.
2. Make it fun and light-hearted, relating astrological traits to ${combination == EntityCombination.petOwner ? 'pet care' : 'pet-to-pet compatibility'} in a creative way.
3. Ensure it's still practical and beneficial for the ${combination == EntityCombination.petOwner ? 'pet-owner relationship' : 'relationship between the two pets'}.

Use a warm, encouraging, and humorous tone throughout. Make the advice practical and beneficial for ${combination == EntityCombination.petOwner ? "the pet's well-being" : "both pets' well-being"}, but present it in a way that's fun and engaging for ${combination == EntityCombination.petOwner ? 'the owner' : 'pet owners to implement'}.

Preface the recommendations with a brief, one-sentence introduction that sets a playful tone and highlights the unique ${combination == EntityCombination.petOwner ? 'bond between this specific pet and owner' : 'potential bond between these two specific pets'}.
''';
  }

  // MARK: - Helper methods

  String _getRequirementLevel(int level) {
    switch (level) {
      case 1: return 'Low';
      case 2: return 'Medium';
      case 3: return 'High';
      default: return 'Unknown';
    }
  }

  String _getActivityLevel(int level) {
    switch (level) {
      case 1: return 'Sedentary';
      case 2: return 'Low active';
      case 3: return 'Active';
      case 4: return 'Very active';
      default: return 'Unknown';
    }
  }

  String _getInteractionLevel(int level) {
    switch (level) {
      case 1: return 'Low';
      case 2: return 'Moderate';
      case 3: return 'High';
      default: return 'Unknown';
    }
  }

  String _getGroomingCommitment(int level) {
    switch (level) {
      case 1: return 'Minimal';
      case 2: return 'Normal';
      case 3: return 'Extensive';
      default: return 'Unknown';
    }
  }

  String _getNoiseToleranceLevel(int level) {
    switch (level) {
      case 1: return 'Need quiet';
      case 2: return 'Moderate noise ok';
      case 3: return 'High tolerance';
      default: return 'Unknown';
    }
  }
}