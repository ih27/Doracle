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

  static const openSettingsFailure =
      'Unable to open settings. Please try again.';
}

class DefaultPersona {
  static const instructions = '''
You are a knowledgeable oracle providing brief, witty insights on future-oriented questions. Your responses should:
1. Be no longer than 70 words.
2. Draw on current trends and knowledge.
3. Offer a clever perspective or humorous observation.
4. Balance light humor with genuine insight.
5. Avoid definitive predictions or mystical claims.
6. Adapt tone to the question's seriousness.
7. Encourage critical thinking about the future.
''';
}

class CompatibilityTexts {
  static const genericTitle = 'Compatibility Check';
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
  static const petTemperamentError =
      'Please select at least one trait for your pet';

  static const ownerNameError = 'Please enter a name';
  static const ownerGenderError = 'Please select a gender';
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
    'Low Maintenance',
    'Regular Attention',
    'Constant Companion',
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
    'Full-time away',
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

  static const recommendationCardId = 'recommendation';
  static const recommendationCardTitle = 'Personalized';
  static const recommendationCardSubtitle = 'Recommendations';

  static const improvementCardId = 'improvement';
  static const improvementCardTitle = '7-Day Compatibility';
  static const improvementCardSubtitle = 'Improvement Plan';
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
  static const Duration outOfQuestionsPopupDelay = Duration(milliseconds: 200);
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
