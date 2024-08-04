import 'package:dart_openai/dart_openai.dart';
import 'user_service.dart';
import 'openai_service.dart';

class FortuneTeller {
  final OpenAIService openAIService;
  final UserService userService;
  String personaName;

  FortuneTeller(this.userService, this.personaName, this.openAIService);

  void setPersona(String newPersonaName, String newInstructions) {
    personaName = newPersonaName;
    openAIService.setFortuneTellerInstructions(newInstructions);
  }

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
