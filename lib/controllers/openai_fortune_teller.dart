import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'fortune_teller.dart';
import '../services/openai_service.dart';
import '../services/user_service.dart';

class OpenAIFortuneTeller implements FortuneTeller {
  late OpenAIService _openAIService;
  @override
  final UserService userService;

  OpenAIFortuneTeller(String instructions, this.userService) {
    _openAIService = OpenAIService(dotenv.env['OPENAI_API_KEY']!, instructions);
  }
  
  @override
  Stream<String> getFortune(String question) async* {
    // Update user's fortune data
    await userService.updateUserFortuneData(question);

    // Get the fortune from OpenAI
    Stream<OpenAIStreamChatCompletionModel> completionStream =
        _openAIService.getFortune(question);
    
    await for (var event in completionStream) {
      yield event.choices.first.delta.content
              ?.map((contentItem) => contentItem?.text ?? '')
              .join() ??
          '';
    }
  }
}