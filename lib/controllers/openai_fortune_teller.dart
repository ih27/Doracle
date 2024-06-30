import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'fortune_teller.dart';
import '../services/openai_service.dart';

class OpenAIFortuneTeller implements FortuneTeller {
  late OpenAIService _openAIService;
  late Stream completionStream;

  OpenAIFortuneTeller(String instructions) {
    _openAIService = OpenAIService(dotenv.env['OPENAI_API_KEY']!, instructions);
  }
  
  @override
  Stream<String> getFortune(String question) {
    Stream<OpenAIStreamChatCompletionModel> completionStream =
        _openAIService.getFortune(question);
    return completionStream.map((event) {
      return event.choices.first.delta.content
              ?.map((contentItem) => contentItem?.text ?? '')
              .join() ??
          '';
    });
  }
}
