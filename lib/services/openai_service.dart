import 'package:dart_openai/dart_openai.dart';

class OpenAIService {
  final String apiKey;
  final String model = 'gpt-3.5-turbo';
  final systemMessage = OpenAIChatCompletionChoiceMessageModel(
    content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
          'I want you to act like a wise fortune '
          'teller. I want you to respond and answer like her using the tone, manner, '
          'and vocabulary a wise fortune teller would use. Do not write any explanations. '
          'You will act like you know all and see all about the future.')
    ],
    role: OpenAIChatMessageRole.system,
  );

  OpenAIService(this.apiKey) {
    OpenAI.apiKey = apiKey;
    OpenAI.requestsTimeOut = const Duration(seconds: 60);
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
