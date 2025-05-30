import 'package:dart_openai/dart_openai.dart';
import '../helpers/constants.dart';

class OpenAIService {
  final String apiKey;
  String fortuneTellerInstructions;
  String compatibilityGuesserInstructions;
  String dailyHoroscopeInstructions;
  final String model = OpenAIConstants.model;
  late OpenAIChatCompletionChoiceMessageModel fortuneTellerSystemMessage;
  late OpenAIChatCompletionChoiceMessageModel compatibilityGuesserSystemMessage;
  late OpenAIChatCompletionChoiceMessageModel dailyHoroscopeSystemMessage;

  OpenAIService(this.apiKey, this.fortuneTellerInstructions,
      this.compatibilityGuesserInstructions, this.dailyHoroscopeInstructions) {
    OpenAI.apiKey = apiKey;
    OpenAI.requestsTimeOut = OpenAIConstants.requestTimeout;
    _initializeFortuneTellerSystemMessage();
    _initializeCompatibilityGuesserSystemMessage();
    _initializeDailyHoroscopeSystemMessage();
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

  void _initializeDailyHoroscopeSystemMessage() {
    dailyHoroscopeSystemMessage =
        OpenAIChatCompletionChoiceMessageModel(content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(
          dailyHoroscopeInstructions)
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

  void setDailyHoroscopeInstructions(String newInstructions) {
    dailyHoroscopeInstructions = newInstructions;
    _initializeDailyHoroscopeSystemMessage();
  }

  Stream<OpenAIStreamChatCompletionModel> getFortune(String question) {
    final userMessage = OpenAIChatCompletionChoiceMessageModel(content: [
      OpenAIChatCompletionChoiceMessageContentItemModel.text(question)
    ], role: OpenAIChatMessageRole.user);

    return OpenAI.instance.chat.createStream(
      model: model,
      messages: [fortuneTellerSystemMessage, userMessage],
      n: 1,
      maxTokens: OpenAIConstants.fortuneMaxTokens,
      temperature: OpenAIConstants.defaultTemperature,
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
      n: 1,
      temperature: OpenAIConstants.defaultTemperature,
      responseFormat: OpenAIConstants.jsonResponseFormat,
    );
  }

  Future<OpenAIChatCompletionModel> getDailyHoroscope(String prompt) async {
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)],
      role: OpenAIChatMessageRole.user,
    );

    return await OpenAI.instance.chat.create(
      model: model,
      messages: [dailyHoroscopeSystemMessage, userMessage],
      n: 1,
      temperature: OpenAIConstants.defaultTemperature,
      responseFormat: OpenAIConstants.jsonResponseFormat,
    );
  }
}
