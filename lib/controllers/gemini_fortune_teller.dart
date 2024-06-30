import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'fortune_teller.dart';
import '../services/gemini_service.dart';

class GeminiFortuneTeller implements FortuneTeller {
  late GeminiService _geminiService;
  late Stream completionStream;

  GeminiFortuneTeller(String instructions) {
    _geminiService = GeminiService(dotenv.env['GEMINI_API_KEY']!, instructions);
  }

  @override
  Stream<String> getFortune(String question) {
    Stream<GenerateContentResponse> completionStream =
        _geminiService.getFortune(question);
    return completionStream.map((event) => event.text ?? '');
  }
}
