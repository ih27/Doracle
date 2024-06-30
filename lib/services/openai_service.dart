import 'package:dart_openai/dart_openai.dart';

class OpenAIService {
  final String apiKey;
  final String model = 'gpt-3.5-turbo';
  late OpenAIChatCompletionChoiceMessageModel systemMessage;

  OpenAIService(this.apiKey, String instructions) {
    OpenAI.apiKey = apiKey;
    OpenAI.requestsTimeOut = const Duration(seconds: 60);
    systemMessage = OpenAIChatCompletionChoiceMessageModel(content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(instructions)
    ], role: OpenAIChatMessageRole.system);
  }

  Stream<OpenAIStreamChatCompletionModel> getFortune(String question) {
    final userMessage = OpenAIChatCompletionChoiceMessageModel(content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(question)
    ], role: OpenAIChatMessageRole.user);

    return OpenAI.instance.chat.createStream(
      model: model,
      messages: [systemMessage, userMessage],
      seed: 423,
      n: 1,
      maxTokens: 100,
      temperature: 0.5,
    );
  }
}
