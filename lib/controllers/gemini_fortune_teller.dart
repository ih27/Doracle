import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'fortune_teller.dart';
import '../services/gemini_service.dart';
import '../services/user_service.dart';

class GeminiFortuneTeller implements FortuneTeller {
  late GeminiService _geminiService;
  @override
  final UserService userService;

  GeminiFortuneTeller(String instructions, this.userService) {
    _geminiService = GeminiService(dotenv.env['GEMINI_API_KEY']!, instructions);
  }

  @override
  Stream<String> getFortune(String question) async* {
    // Update user's fortune data
    await userService.updateUserFortuneData(question);

    // Get the fortune from Gemini
    Stream<GenerateContentResponse> completionStream =
        _geminiService.getFortune(question);
    
    await for (var event in completionStream) {
      yield event.text ?? '';
    }
  }
}