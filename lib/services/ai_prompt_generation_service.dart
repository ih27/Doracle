import '../models/pet_model.dart';
import '../models/owner_model.dart';

enum PromptType {
  tenDayPlan,
  astrologicalCompatibility,
  personalizedRecommendations,
  dailyPetHoroscope,
  dailyOwnerHoroscope,
}

enum EntityCombination {
  petOwner,
  petPet,
  ownerPets,
  singlePet,
  singleOwner,
}

class AIPromptGenerationService {
  // MARK: - Public methods

  String generatePrompt(PromptType type,
      {Pet? pet, Owner? owner, Pet? secondPet, List<Pet>? pets}) {
    final combination =
        _determineEntityCombination(pet, owner, secondPet, pets);
    return _generatePromptForType(type, combination,
        pet: pet, owner: owner, secondPet: secondPet, pets: pets);
  }

  EntityCombination _determineEntityCombination(
      Pet? pet, Owner? owner, Pet? secondPet, List<Pet>? pets) {
    if (owner != null && pet != null) {
      return EntityCombination.petOwner;
    }
    if (pet != null && secondPet != null) {
      return EntityCombination.petPet;
    }
    if (owner != null && pets != null) {
      return EntityCombination.ownerPets;
    }
    if (pet != null) {
      return EntityCombination.singlePet;
    }
    if (owner != null) {
      return EntityCombination.singleOwner;
    }
    throw ArgumentError('Invalid entity combination');
  }

  // MARK: - Internal methods

  String _generatePromptForType(PromptType type, EntityCombination combination,
      {Pet? pet, Owner? owner, Pet? secondPet, List<Pet>? pets}) {
    final basePrompt = _getBasePrompt(type, combination);
    final entityInfo = _getEntityInfo(combination,
        pet: pet, owner: owner, secondPet: secondPet, pets: pets);
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
      case PromptType.dailyPetHoroscope:
        return "Generate a fun and engaging daily horoscope for a pet in JSON format.";
      case PromptType.dailyOwnerHoroscope:
        return "Generate a concise daily horoscope for a zodiac sign in JSON format.";
    }
  }

  String _getEntityInfo(EntityCombination combination,
      {Pet? pet, Owner? owner, Pet? secondPet, List<Pet>? pets}) {
    switch (combination) {
      case EntityCombination.petOwner:
        return '''
${_getPetInfo(pet!)}

Owner Information:
${_getOwnerInfo(owner!)}
''';
      case EntityCombination.petPet:
        return '''
${_getPetInfo(pet!)}

Pet B Information:
${_getPetInfo(secondPet!, isPetB: true)}
''';
      case EntityCombination.ownerPets:
        return '''
Owner Information:
${_getOwnerInfo(owner!)}

Pets Information:
${pets!.map((p) => _getPetInfo(p, isShort: true)).join('\n')}
''';
      case EntityCombination.singlePet:
        return _getPetInfo(pet!);
      case EntityCombination.singleOwner:
        return _getOwnerInfo(owner!);
    }
  }

  String _getPetInfo(Pet pet, {bool isPetB = false, bool isShort = false}) {
    if (isShort) {
      return "- ${pet.name}: ${pet.species}, Born: ${pet.birthdate}, Zodiac Sign: ${_getZodiacSign(pet.birthdate)}";
    }
    return '''
${isPetB ? 'Pet B' : 'Pet'} Information:
- Name: ${pet.name}
- Type: ${pet.species}
- Date of Birth: ${pet.birthdate}
- Time of Birth: ${pet.birthtime}
- Temperament: ${pet.temperament.join(', ')}
- Exercise Requirement: ${_getRequirementLevel(pet.exerciseRequirement)}
- Social Needs: ${_getRequirementLevel(pet.socializationNeed)}
- Zodiac Sign: ${_getZodiacSign(pet.birthdate)}
''';
  }

  String _getOwnerInfo(Owner owner) {
    return '''
- Name: ${owner.name}
- Date of Birth: ${owner.birthdate}
- Time of Birth: ${owner.birthtime}
- Living Situation: ${owner.livingSituation}
- Daily Activity Level: ${_getActivityLevel(owner.activityLevel)}
- Desired Interaction Level: ${_getInteractionLevel(owner.interactionLevel)}
- Work Schedule: ${owner.workSchedule}
- Pet Experience: ${owner.petExperience}
- Grooming Commitment: ${_getGroomingCommitment(owner.groomingCommitment)}
- Noise Tolerance: ${_getNoiseToleranceLevel(owner.noiseTolerance)}
- Primary Reason for Pet: ${owner.petReason}
- Zodiac Sign: ${_getZodiacSign(owner.birthdate)}
''';
  }

  String _getSpecificInstructions(
      PromptType type, EntityCombination combination) {
    switch (type) {
      case PromptType.tenDayPlan:
        return _getTenDayPlanInstructions(combination);
      case PromptType.astrologicalCompatibility:
        return _getAstrologyInstructions(combination);
      case PromptType.personalizedRecommendations:
        return _getRecommendationsInstructions(combination);
      case PromptType.dailyPetHoroscope:
        return _getPetHoroscopeInstructions(combination);
      case PromptType.dailyOwnerHoroscope:
        return _getOwnerHoroscopeInstructions(combination);
    }
  }

  String _getTenDayPlanInstructions(EntityCombination combination) {
    String common = '''
Generate a 10-day ${combination == EntityCombination.petOwner ? 'compatibility improvement plan for a pet and their owner' : 'action plan to improve the compatibility and relationship between two pets'} in the following JSON format:

{
  "introduction": "A brief, encouraging introduction (1 sentence) that motivates ${combination == EntityCombination.petOwner ? 'the owner' : 'the pet owners'} to commit to the 10-day journey.",
  "compatibility_improvement_plan": [
    {
      "day": 1,
      "title": "Catchy title for the day's theme",
      "task": "A specific task or activity (1-2 sentences)",
      "benefit": "The purpose or benefit of the activity (1 sentence)",
      "tip": "A quick tip for success (1 sentence)"
    },
    // ... repeat for all 10 days
  ],
  "conclusion": "A short conclusion (1 sentence) that encourages continuing the positive habits formed and celebrates the strengthened bond."
}

For each day in the compatibility_improvement_plan:
1. Provide a catchy title for the day's theme
2. Describe a specific task or activity (1-2 sentences)
3. Explain the purpose or benefit of the activity (1 sentence)
4. Include a quick tip for success (1 sentence)

The plan should:
1. Address different aspects of ${combination == EntityCombination.petOwner ? 'pet care and bonding' : 'compatibility and relationship building'}
2. Be progressive, starting with simpler tasks and building up
3. Take into account the ${combination == EntityCombination.petOwner ? "pet's needs and owner's lifestyle" : "needs and temperaments of both pets"}
4. Include a mix of quick daily habits and longer, more involved activities
5. Be fun and engaging while also practical and beneficial
''';

    if (combination == EntityCombination.petOwner) {
      common +=
          "6. Incorporate activities that align with the owner's primary reason for having a pet\n";
    } else {
      common += '''
6. Consider the potential challenges of the specific pet type combination when designing tasks
7. Incorporate rest days or lower-intensity days to prevent overwhelming the pets
8. Include tasks that involve the pet owners in facilitating positive interactions between the pets
''';
    }

    return common;
  }

  String _getAstrologyInstructions(EntityCombination combination) {
    return '''
First, determine the zodiac signs based on the birthdates provided. Then, create output in the following JSON format:

{
  "introduction": "A brief note stating the determined zodiac signs",
  "elementalHarmony": {
    "title": "Catchy title related to elements",
    "content": "About 50 words discussing how the elements of their signs interact. Include the determined sun signs."
  },
  "planetaryInfluence": {
    "title": "Title mentioning ruling planets",
    "content": "About 50 words explaining how the planetary rulers influence their relationship. Include the determined sun signs and their ruling planets."
  },
  "sunSignCompatibility": {
    "title": "Title highlighting sun sign pairing",
    "content": "About 50 words describing how their sun signs complement or challenge each other. Explicitly state the determined sun signs."
  },
  "moonSignSynergy": {
    "title": "Title about emotional connection",
    "content": "If birth hours are provided, determine the moon signs and write about 50 words on how their moon signs affect their emotional bond. If birth hours are not available, provide a general statement about emotional compatibility based on sun signs. Mention if this is based on sun or moon signs."
  }
}

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
Based on this information, create 5 practical recommendations and 1 astrological bonus tip. Provide the response in the following JSON format:
{
  "introduction": "One-sentence introduction setting a playful tone",
  "practicalRecommendations": [
    "2-3 sentences for recommendation 1",
    "2-3 sentences for recommendation 2",
    "2-3 sentences for recommendation 3",
    "2-3 sentences for recommendation 4",
    "2-3 sentences for recommendation 5"
  ],
  "astrologicalBonusTip": "2-3 sentences for the astrological bonus tip"
}
  
Each practical recommendation should:
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

  String _getPetHoroscopeInstructions(EntityCombination combination) {
    return '''
Generate a fun and engaging daily horoscope for pets in the following JSON format:

{
  "petName": "[PET_NAME]",
  "petSpecies": "[PET_SPECIES]",
  "dailyVibe": {
    "theme": "[THEME_OF_THE_DAY]",
    "emoji": "[EMOJI]"
  },
  "playtimeAndBonding": {
    "morning": "[BRIEF_MORNING_ACTIVITY]",
    "evening": "[BRIEF_EVENING_ACTIVITY]"
  },
  "homeAdventures": [
    "[FUN_HOME_ACTIVITY_1]",
    "[FUN_HOME_ACTIVITY_2]"
  ],
  "treatsAndNaps": {
    "todaysSnack": "[TREAT_SUGGESTION]",
    "napSpot": "[NAP_LOCATION_IDEA]"
  },
  "walkiesAndExercise": [
    "[OUTDOOR_ACTIVITY_SUGGESTION]",
    "[SIMPLE_EXERCISE_IDEA]"
  ],
  "cosmicCanineWisdom": "[SHORT_INSPIRATIONAL_QUOTE_FOR_PETS]",
  "quickBoosters": {
    "luckyToy": "[SPECIFIC_TOY_SUGGESTION]",
    "powerMove": "[CUTE_PET_BEHAVIOR]",
    "goodDeed": "[KIND_ACTION_FOR_PETS]"
  },
  "message": "[0NE_SENTENCE_WITH_POSITIVE_VIBE]"
}

Guidelines for generation:
1. Adjust [PET_SPECIES] to match the target pet type (dog, cat, bird, fish).
2. Keep the language simple, playful, and pet-oriented.
3. Ensure all suggested activities are safe and appropriate for pets.
4. Vary the content daily while maintaining a consistent structure.
5. Include a mix of indoor and outdoor activities.
6. Add subtle reminders for pet care when possible.
7. Use pet-related emojis sparingly to enhance readability.
8. Limit the entire horoscope to around 150-200 words when combined.
9. Ensure the overall tone is positive, fun, and engaging for pet owners.
10. Use proper JSON formatting, ensuring all strings are properly escaped.
11. Replace [PLACEHOLDERS] with appropriate content tailored to different pet types and personalities.
12. [0NE_SENTENCE_WITH_POSITIVE_VIBE] should include [PET_NAME] and some fun emoji(s).
''';
  }

  String _getOwnerHoroscopeInstructions(EntityCombination combination) {
    return '''
Generate a concise daily horoscope for [ZODIAC_SIGN] in the following JSON format:

{
  "zodiacSign": "[ZODIAC_SIGN]",
  "dailyVibe": {
    "theme": "[THEME_OF_THE_DAY]",
    "emoji": "[EMOJI]"
  },
  "relationships": {
    "morning": "[BRIEF_MORNING_ADVICE]",
    "evening": "[BRIEF_EVENING_ADVICE]"
  },
  "workAndProductivity": {
    "keyAdvice": "[KEY_WORK_ADVICE]",
    "productivityTip": "[PRODUCTIVITY_TIP]"
  },
  "homeAndSelfCare": {
    "homeTask": "[HOME_TASK]",
    "selfCareActivity": "[SELF_CARE_ACTIVITY]"
  },
  "healthAndWellness": {
    "nutritionAdvice": "[NUTRITION_ADVICE]",
    "exerciseOrWellnessSuggestion": "[EXERCISE_OR_WELLNESS_SUGGESTION]"
  },
  "cosmicInsight": "[SHORT_INSPIRATIONAL_QUOTE]"
}

Guidelines:
1. Keep each point brief and actionable.
2. Tailor advice to [ZODIAC_SIGN]'s typical traits and current astrological influences.
3. Ensure the overall tone is positive and empowering.
4. Vary content daily while maintaining relevance to the zodiac sign.
5. Limit the entire horoscope to around 100-150 words when combined.
6. Use proper JSON formatting, ensuring all strings are properly escaped.
7. Replace [PLACEHOLDERS] with appropriate content for the specific zodiac sign and day.
''';
  }

  // MARK: - Helper methods

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

  String _getZodiacSign(String? birthdate) {
    if (birthdate == null) return "Unknown";

    List<String> parts = birthdate.split('/');
    if (parts.length != 3) return "Unknown";

    int day, month;
    try {
      day = int.parse(parts[0]);
      month = int.parse(parts[1]);
    } catch (e) {
      return "Unknown";
    }

    switch (month) {
      case 1: // January
        return (day <= 19) ? "Capricorn" : "Aquarius";
      case 2: // February
        return (day <= 18) ? "Aquarius" : "Pisces";
      case 3: // March
        return (day <= 20) ? "Pisces" : "Aries";
      case 4: // April
        return (day <= 19) ? "Aries" : "Taurus";
      case 5: // May
        return (day <= 20) ? "Taurus" : "Gemini";
      case 6: // June
        return (day <= 20) ? "Gemini" : "Cancer";
      case 7: // July
        return (day <= 22) ? "Cancer" : "Leo";
      case 8: // August
        return (day <= 22) ? "Leo" : "Virgo";
      case 9: // September
        return (day <= 22) ? "Virgo" : "Libra";
      case 10: // October
        return (day <= 22) ? "Libra" : "Scorpio";
      case 11: // November
        return (day <= 21) ? "Scorpio" : "Sagittarius";
      case 12: // December
        return (day <= 21) ? "Sagittarius" : "Capricorn";
      default:
        return "Unknown";
    }
  }
}
