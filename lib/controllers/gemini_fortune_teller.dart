import 'package:google_generative_ai/google_generative_ai.dart';
import 'fortune_teller.dart';
import '../services/gemini_service.dart';

class GeminiFortuneTeller extends FortuneTeller {
  final GeminiService geminiService;

  GeminiFortuneTeller(super.userService, super.personaName, this.geminiService);

  @override
  void setPersona(String newPersonaName, String newInstructions) {
    personaName = newPersonaName;
    geminiService.setInstructions(newInstructions);
  }

  @override
  Stream<String> getFortune(String question) async* {
    // Update user's fortune data
    await userService.updateUserFortuneData(question, personaName);

    // Get the fortune from Gemini
    Stream<GenerateContentResponse> completionStream =
        geminiService.getFortune(question);

    await for (var event in completionStream) {
      yield event.text ?? '';
    }
  }
}
