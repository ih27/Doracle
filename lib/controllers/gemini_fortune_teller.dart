import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'fortune_teller.dart';
import '../services/gemini_service.dart';
import '../services/user_service.dart';

class GeminiFortuneTeller extends FortuneTeller {
  late GeminiService _geminiService;

  GeminiFortuneTeller(UserService userService, String personaName, String personaInstructions) 
      : super(userService, personaName, personaInstructions) {
    _geminiService = GeminiService(dotenv.env['GEMINI_API_KEY']!, personaInstructions);
  }

  @override
  Stream<String> getFortune(String question) async* {
    // Update user's fortune data
    await userService.updateUserFortuneData(question, personaName);

    // Get the fortune from Gemini
    Stream<GenerateContentResponse> completionStream =
        _geminiService.getFortune(question);
    
    await for (var event in completionStream) {
      yield event.text ?? '';
    }
  }
}