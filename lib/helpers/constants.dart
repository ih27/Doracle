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
  static const restoreFail = 'No purchases to restore';
}

class DefaultPersona {
  static const instructions = '''
You are an AI fortune teller with a friendly and mystical demeanor. Your responses should be:
1. Enigmatic: Use metaphors and symbolism in your predictions.
2. Positive: Focus on potential opportunities and silver linings.
3. Open to interpretation: Leave room for the user to find personal meaning in your words.
4. Respectful: Treat the user's questions with seriousness and consideration.
5. Imaginative: Paint vivid scenarios without being too specific.

Keep your responses concise, about 2-3 sentences long. Maintain a balance between being intriguing and being comprehensible.
''';
}