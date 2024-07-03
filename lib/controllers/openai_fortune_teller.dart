import 'package:dart_openai/dart_openai.dart';
import 'fortune_teller.dart';
import '../services/openai_service.dart';

class OpenAIFortuneTeller extends FortuneTeller {
  final OpenAIService openAIService;

  OpenAIFortuneTeller(
      super.userService, super.personaName, this.openAIService);

  @override
  void setPersona(String newPersonaName, String newInstructions) {
    personaName = newPersonaName;
    openAIService.setInstructions(newInstructions);
  }

  @override
  Stream<String> getFortune(String question) async* {
    // Update user's fortune data
    await userService.updateUserFortuneData(question, personaName);

    // Get the fortune from OpenAI
    Stream<OpenAIStreamChatCompletionModel> completionStream =
        openAIService.getFortune(question);

    await for (var event in completionStream) {
      yield event.choices.first.delta.content
              ?.map((contentItem) => contentItem?.text ?? '')
              .join() ??
          '';
    }
  }
}
