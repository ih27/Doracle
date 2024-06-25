import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fortuntella/controllers/fortune_teller.dart';
import 'package:fortuntella/services/gemini_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiFortuneTeller implements FortuneTeller {
  final GeminiService _geminiService;
  late Stream completionStream;

  GeminiFortuneTeller()
      : _geminiService = GeminiService(dotenv.env['GEMINI_API_KEY']!);

  @override
  Stream<String> getFortune(String question) {
    Stream<GenerateContentResponse> completionStream =
        _geminiService.getFortune(question);
    return completionStream.map((event) => event.text ?? '');
  }

  @override
  void onFortuneReceived(Function(String) callback, Function(String) onError) {
    completionStream.listen(
      (fortunePart) {
        callback(fortunePart);
      },
      onDone: () {
        callback('🔮');
      },
      onError: (error) {
        onError('Unexpected error occurred. Error: $error');
      },
    );
  }
}
