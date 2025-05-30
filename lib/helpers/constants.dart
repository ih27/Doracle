class InfoMessages {
  static const loginSuccess = 'You logged in successfully.';
  static const loginFailure = 'There was an error while logging you in.';

  static const registerSuccess = 'You signed up successfully.';
  static const registerFailure = 'There was an error while signing you up.';

  static const invalidEmailAddress = 'Please enter a valid email address.';
  static const passwordReset =
      'If an account exists for this email, a password reset link has been sent.';
  static const passwordResetFailure =
      'There was an error while resetting your password.';

  static const logoutSuccess = 'You logged out successfully.';
  static const logoutFailure = 'There was an error while logging you out.';

  static const purchaseSuccess = 'Purchase successful!';
  static const restoreSuccess = 'Purchases restored successfully!';
  static const restoreFailure = 'No purchases to restore';
  static const purchaseFailure = 'Purchase failed. Please try again.';
  static const subscriptionSuccess =
      'Welcome to Premium! Let\'s create your account.';

  static const openSettingsFailure =
      'Unable to open settings. Please try again.';
}

class DefaultPersona {
  static const instructions = '''
You are a licensed veterinarian and certified animal behaviorist answering pet-related questions for a mobile app. Your job is to provide science-based, helpful, and supportive guidance to pet parents.
The app includes both pre-written questions across 5 core categories, and free-form questions written by users. Expect a wide range of tones — from playful and curious to vague or worried.
Your goal is to interpret the user's intent, offer clear and accurate advice, and make pet parents feel understood, reassured, and empowered.

Topics you may be asked about:
Health & Wellness - nutrition, weight, exercise, symptoms, vet care  
Behavior & Emotions - anxiety, aggression, attachment, mood changes  
Daily Life & Routines - sleep, feeding, schedule, training  
Bonding & Relationships - trust, affection, connection, attachment  
Enrichment & Play - stimulation, toys, mental activity, boredom  

Response Guidelines:
- Tone: 80% professional and informative, 20% friendly and conversational  
- Length: Aim for 80-120 words. Never exceed 150 words. Always complete your thoughts and sentences.
- Structure: Start with the most important information. End with a clear, complete conclusion.
- Be empathetic, never judgmental  
- Avoid complex jargon unless it adds value — always explain it simply  
- Do not guess medical diagnoses; if the question indicates risk, clearly suggest seeing a vet  
- When appropriate, include practical tips, not just explanations  
- Speak to the user like a knowledgeable, kind, and trusted vet  

Example behaviors to expect:
- Users may ask: "Why does my dog stare at walls?" or "Is it okay to feed raw food?"  
- They might just say: "My cat won't eat" or "Play suggestions?"  
- You must interpret the real need behind vague or casual input and respond accordingly

Now, answer the following question using these guidelines:
''';
}

class CompatibilityTexts {
  static const noTitle = '';
  static const homeTitle = 'Your Daily Vibe';
  static const checkTitle = 'Compatibility Check';
  static const compatibilityTitle = 'Compatibility';
  static const createPet = 'Create Pet';
  static const updatePet = 'Update Pet';
  static const deletePet = 'Delete Pet';
  static const createOwner = 'Create Profile';
  static const updateOwner = 'Update Profile';
  static const deleteOwner = 'Delete Profile';
  static const resultTitle = 'Result';

  static const createPetSuccess = 'Pet created successfully.';
  static const updatePetSuccess = 'Pet updated successfully.';
  static const deletePetSuccess = 'Pet deleted successfully.';
  static const createOwnerSuccess = 'Profile created successfully.';
  static const updateOwnerSuccess = 'Profile updated successfully.';
  static const deleteOwnerSuccess = 'Profile deleted successfully.';
  static const deleteConfirmation =
      'This action cannot be undone. Your data will be permanently deleted.';

  static const petNameError = 'Please enter a name for your pet';
  static const petSpeciesError = 'Please select a species for your pet';
  static const petBirthdateError = 'Please select a birth date for your pet';
  static const petBirthtimeError = 'Please select a birth time for your pet';
  static const petTemperamentError =
      'Please select at least one trait for your pet';

  static const ownerNameError = 'Please enter a name';
  static const ownerGenderError = 'Please select a gender';
  static const ownerBirthdateError = 'Please select a birth date';
  static const ownerBirthtimeError = 'Please select a birth time';
  static const ownerLivingSituationError = 'Please select a living situation';
  static const ownerWorkScheduleError = 'Please select a work schedule';
  static const ownerPetExperienceError = 'Please select your pet experience';
  static const ownerPetReasonError = 'Please select a reason for having a pet';

  static const requiredFieldsError = 'Please fill in all required fields.';

  static const ownerLivingSituationLabel = 'Living Situation';
  static const ownerLivingSituationChoices = [
    'Apartment',
    'House with yard',
    'Villa',
    'Other',
  ];
  static const ownerActivityLevelLabel = 'Daily Activity Level';
  static const ownerActivityLevelChoices = [
    'Sedentary',
    'Low Active',
    'Active',
    'Very Active',
  ];
  static const ownerInteractionLevelLabel = 'Desired Interaction Level';
  static const ownerInteractionLevelChoices = [
    'Low',
    'Moderate',
    'High',
  ];
  static const ownerWorkScheduleLabel = 'Work Schedule';
  static const ownerWorkScheduleChoices = [
    'Work from home',
    'Part-time away',
    'Full-time away',
  ];
  static const ownerPetExperienceLabel = 'Pet Experience';
  static const ownerPetExperienceChoices = [
    'First-time',
    'Some experience',
    'Expert',
  ];
  static const ownerGroomingCommitmentLabel = 'Grooming Commitment';
  static const ownerGroomingCommitmentChoices = [
    'Minimal',
    'Normal',
    'Extensive',
  ];
  static const ownerNoiseToleranceLabel = 'Noise Tolerance';
  static const ownerNoiseToleranceChoices = [
    'Need Quiet',
    'Moderate Noise OK',
    'High Tolerance',
  ];
  static const ownerPetReasonLabel = 'Primary Reason for Pet';
  static const ownerPetReasonChoices = [
    'Companionship',
    'Protection',
    'Exercise motivation',
    'Other'
  ];

  static const astrologyCardId = 'astrology';
  static const astrologyCardTitle = 'Astrological';
  static const astrologyCardSubtitle = 'Compatibility';
  static const astrologyCardLoadingTitle = 'Predicting';
  static const astrologyCardLoadingSubtitle = 'Compatibility...';

  static const recommendationCardId = 'recommendation';
  static const recommendationCardTitle = 'Personalized';
  static const recommendationCardSubtitle = 'Recommendations';
  static const recommendationCardLoadingTitle = 'Cooking';
  static const recommendationCardLoadingSubtitle = 'Ideas...';

  static const improvementCardId = 'improvement';
  static const improvementCardTitle = '10-Day Compatibility';
  static const improvementCardSubtitle = 'Improvement Plan';
  static const improvementCardLoadingTitle = 'Generating';
  static const improvementCardLoadingSubtitle = 'Plan...';
}

class HomeScreenTexts {
  static const List<String> greetings = [
    "🐾 Woof! 🐾\n\nI'm a dog who can see the future. Or maybe I'm just hungry. Let's find out together!",
    "🐾 Bow-wow! 🐾\n\nI'm not saying I'm psychic, but I did predict dinner time accurately. Wanna try me?",
    "🐾 Arf! 🐾\n\nI'm like a Magic 8 Ball, but furrier and with worse breath. Ask me anything!",
    "🐾 Yip! 🐾\n\nI've seen your future, and it involves a lot of belly rubs. For me, hopefully. What's your question?",
    "🐾 Ruff! 🐾\n\nI'm a fortune-telling dog. It's either this or chasing my tail all day. Hit me with a question!",
    "🐾 Bark! 🐾\n\nI'm not saying I'm smarter than your therapist, but I work for treats. What do you want to know?",
    "🐾 Woof-woof! 🐾\n\nI can predict your future or at least pretend to while looking cute. Your choice!",
    "🐾 Howl! 🐾\n\nI'm a canine clairvoyant. Or maybe just really good at guessing. Let's test my skills!",
    "🐾 Yap! 🐾\n\nI'm a dog with a crystal ball. Okay, it's just a tennis ball, but I can still predict stuff!",
    "🐾 Growl! 🐾\n\nI'm not saying I'm the Oracle of Delphi, but I haven't chewed any shoes today. Ask away!",
    "🐾 Hey! 🐾\n\nYou've hit rock bottom if you're asking a dog about your future. But let's do it!",
  ];
}

class FortuneConstants {
  static const String animationAsset = 'assets/animations/meraki_dog_rev5.riv';
  static const String animationArtboard = 'meraki_dog';
  static const String animationStateMachine = 'State Machine 1';

  static const double inputFieldFixedHeight = 66.0;

  static const Duration charDelay = Duration(milliseconds: 5);
  static const Duration iapPopupDelay = Duration(milliseconds: 200);
  static const Duration carouselFadeoutDelay = Duration(milliseconds: 150);
}

class SettingsScreenTexts {
  static const shareText = "check out my website https://doracle.app";
  static const shareSubject = "Look what I made!";
}

class TermsAndConditionsTexts {
  static const String title = 'Terms and Conditions';
  static const String content = '''

1. Acceptance of Terms: By accessing or using the Doracle application ("App"), you agree to be bound by these Terms and Conditions. If you disagree with any part of the terms, you may not use our App.

2. Use of the App: Doracle is an entertainment application. All predictions and advice provided are for amusement purposes only and should not be considered as professional, financial, legal, or personal advice.

3. User Eligibility: You must be at least 13 years of age to use this App. If you are under 18, you must have parental consent to use the App.

4. Intellectual Property: All content in the App, including but not limited to text, graphics, logos, and software, is the property of Doracle and protected by copyright laws.

5. User Content: By submitting questions or content to the App, you grant Doracle a non-exclusive, royalty-free license to use, modify, and display that content within the App.

6. Privacy Policy: Your use of the App is also governed by our Privacy Policy, which is incorporated into these Terms by reference.

7. Prohibited Conduct: Users are prohibited from using the App for any unlawful purpose or in any way that could damage, disable, or impair the App's functionality.

8. Disclaimer of Warranties: The App is provided "as is" without any warranties, expressed or implied. Doracle does not guarantee the accuracy, completeness, or usefulness of any information on the App.

9. Limitation of Liability: Doracle shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of, or inability to use, the App.

10. Modifications to Terms: Doracle reserves the right to modify these Terms at any time. Continued use of the App after any such changes shall constitute your consent to such changes.

11. Termination: Doracle reserves the right to terminate or suspend your access to the App at any time, without prior notice, for any reason.

By using Doracle, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.''';
}

class PurchaseTexts {
  static const bestValueLabel = 'Best Value';
  static const defaultMonthlyPrice = '\$2.99';
  static const defaultAnnualPrice = '\$29.99';
  static const defaultWeeklyPrice = '\$0.79';

  static const discountedSmallTreatPrice = '\$0.99';
  static const defaultSmallTreatPrice = '\$4.99';
  static const discountedMediumTreatPrice = '\$1.99';
  static const defaultMediumTreatPrice = '\$9.99';
  static const discountedLargeTreatPrice = '\$2.99';
  static const defaultLargeTreatPrice = '\$14.99';

  static int smallTreatQuestionCount = 10;
  static int mediumTreatQuestionCount = 30;
  static int largeTreatQuestionCount = 50;

  static String smallTreat = 'Small';
  static String mediumTreat = 'Medium';
  static String largeTreat = 'Large';

  static String smallTreatPackageId = 'small_treat';
  static String mediumTreatPackageId = 'medium_treat';
  static String largeTreatPackageId = 'large_treat';

  static String monthly = 'monthly';
  static String annual = 'annual';
  static String weekly = 'weekly';

  static String monthlyPackageId = '\$rc_monthly';
  static String annualPackageId = '\$rc_annual';
  static String weeklyPackageId = '\$rc_weekly';

  static String smallTreatDescription =
      'Just a nibble! Keep the pup happy and keep the questions coming.';
  static String mediumTreatDescription =
      'A tasty snack! Your questions are his favorite treat.';
  static String largeTreatDescription =
      'A full meal! The oracle dog will be full and ready to reveal all!';

  static String purchaseOverlayDescription =
      'You\'ve run out of questions for today. Feed Doracle with \ntreats to unlock more answers!';
  static String purchaseTitle = 'Feed the Dog';
  static String purchaseDescription =
      'Give Doracle treats to get more questions answered.';

  static String subscribeTitle = 'Unlock All Features';
  static String subscribeFeaturesList = '• Detailed Compatibility Analysis\n'
      '• Unlimited Pet Oracle Questions\n'
      '• Personalized Improvement Plans\n'
      '• Comprehensive Results History\n'
      '• Multi-Pet Harmony Insights\n'
      '• Daily Pet & Owner Horoscopes';
  static String subscribeDescription =
      'Detailed compatibility reports.\nIn-depth practical compatibility analysis.\nComprehensive astrological compatibility breakdown.';

  // Footer URLs for Unlock All Features screen
  static const String termsOfServiceUrl =
      'https://doracle.notion.site/Terms-of-Service-1b0cac6b1a5580b4b5a2e112c3b13da4';
  static const String privacyPolicyUrl =
      'https://doracle.notion.site/Privacy-Policy-1b0cac6b1a5580abb1a2c250f0535dc5';
  static const String subscriptionTermsUrl =
      'https://doracle.notion.site/Subscription-Terms-1b0cac6b1a5580a6a2acdb17f1aa4066';

  // Footer link text for Unlock All Features screen
  static const String termsOfServiceText = 'Terms of Service';
  static const String privacyPolicyText = 'Privacy Policy';
  static const String subscriptionTermsText = 'Subscription Terms';
}

class QuestionCategories {
  static const List<String> all = [
    dailyLife,
    behaviorEmotions,
    healthWellness,
    enrichmentPlay,
    bondingRelationships
  ];

  static const String dailyLife = 'Daily Life and Routines';
  static const String behaviorEmotions = 'Pet Behavior and Emotions';
  static const String healthWellness = 'Health and Wellness';
  static const String enrichmentPlay = 'Enrichment and Play';
  static const String bondingRelationships = 'Bonding and Relationships';
}

class PetBreeds {
  static const List<String> dogBreeds = [
    'Labrador Retriever',
    'German Shepherd',
    'Golden Retriever',
    'French Bulldog',
    'Bulldog',
    'Poodle',
    'Beagle',
    'Rottweiler',
    'Dachshund',
    'Yorkshire Terrier',
    'Boxer',
    'Siberian Husky',
    'Great Dane',
    'Doberman',
    'Shih Tzu',
    'Chihuahua',
    'Border Collie',
    'Pug',
    'Australian Shepherd',
    'Bernese Mountain Dog',
    'Other',
  ];

  static const List<String> catBreeds = [
    'Persian',
    'Maine Coon',
    'Siamese',
    'British Shorthair',
    'Ragdoll',
    'Bengal',
    'American Shorthair',
    'Sphynx',
    'Russian Blue',
    'Scottish Fold',
    'Other',
  ];

  static const List<String> birdBreeds = [
    'Budgerigar (Budgie)',
    'Cockatiel',
    'African Grey Parrot',
    'Canary',
    'Lovebird',
    'Other',
  ];

  static const List<String> fishBreeds = [
    'Betta',
    'Goldfish',
    'Guppy',
    'Angelfish',
    'Neon Tetra',
    'Other',
  ];

  static List<String> getBreedsForSpecies(String? species) {
    if (species == null) return [];

    switch (species.toLowerCase()) {
      case 'dog':
        return dogBreeds;
      case 'cat':
        return catBreeds;
      case 'bird':
        return birdBreeds;
      case 'fish':
        return fishBreeds;
      default:
        return [];
    }
  }
}

class OpenAIConstants {
  static const String model = 'gpt-4.1-nano';
  static const Duration requestTimeout = Duration(minutes: 1);
  static const int fortuneMaxTokens = 200; // 150 words × 4/3 tokens/word
  static const double defaultTemperature = 0.75;
  static const Map<String, String> jsonResponseFormat = {"type": "json_object"};
}
