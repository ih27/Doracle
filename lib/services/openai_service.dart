import 'package:dart_openai/dart_openai.dart';

class OpenAIService {
  final String apiKey;
  final String model = 'gpt-3.5-turbo';

  OpenAIService(this.apiKey) {
    OpenAI.apiKey = apiKey;
    OpenAI.requestsTimeOut = const Duration(seconds: 60);
  }

  Stream<OpenAIStreamCompletionModel> getFortune(String question) {
    return OpenAI.instance.completion.createStream(
        model: model,
        prompt: question,
        maxTokens: 100,
        temperature: 0.5,
        topP: 1,
        seed: 42,
        // stop: '###',
        n: 1);
  }
}
