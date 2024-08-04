import 'package:dart_openai/dart_openai.dart';

class OpenAIService {
  final String apiKey;
  String fortuneTellerInstructions;
  String compatibilityGuesserInstructions;
  final String model = 'gpt-4o-mini';
  late OpenAIChatCompletionChoiceMessageModel fortuneTellerSystemMessage;
  late OpenAIChatCompletionChoiceMessageModel compatibilityGuesserSystemMessage;

  OpenAIService(this.apiKey, this.fortuneTellerInstructions,
      this.compatibilityGuesserInstructions) {
    OpenAI.apiKey = apiKey;
    OpenAI.requestsTimeOut = const Duration(seconds: 20);
    _initializeFortuneTellerSystemMessage();
    _initializeCompatibilityGuesserSystemMessage();
  }

  void _initializeFortuneTellerSystemMessage() {
    fortuneTellerSystemMessage =
        OpenAIChatCompletionChoiceMessageModel(content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
          fortuneTellerInstructions)
    ], role: OpenAIChatMessageRole.system);
  }

  void _initializeCompatibilityGuesserSystemMessage() {
    compatibilityGuesserSystemMessage =
        OpenAIChatCompletionChoiceMessageModel(content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
          compatibilityGuesserInstructions)
    ], role: OpenAIChatMessageRole.system);
  }

  void setFortuneTellerInstructions(String newInstructions) {
    fortuneTellerInstructions = newInstructions;
    _initializeFortuneTellerSystemMessage();
  }

  void setCompatibilityGuesserInstructions(String newInstructions) {
    compatibilityGuesserInstructions = newInstructions;
    _initializeCompatibilityGuesserSystemMessage();
  }

  Stream<OpenAIStreamChatCompletionModel> getFortune(String question) {
    final userMessage = OpenAIChatCompletionChoiceMessageModel(content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(question)
    ], role: OpenAIChatMessageRole.user);

    return OpenAI.instance.chat.createStream(
      model: model,
      messages: [fortuneTellerSystemMessage, userMessage],
      n: 1,
      maxTokens: 120,
      temperature: 0.75,
    );
  }

  Future<OpenAIChatCompletionModel> getCompatibility(String prompt) async {
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)],
      role: OpenAIChatMessageRole.user,
    );

    return await OpenAI.instance.chat.create(
      model: model,
      messages: [compatibilityGuesserSystemMessage, userMessage],
      maxTokens: 500,
      temperature: 0.75,
    );
  }
}
