import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey;
  final String model = 'gemini-1.5-flash';
  late GenerativeModel serviceModel;
  final systemMessage = Content.system('I want you to act like a wise fortune '
      'teller. I want you to respond and answer like her using the tone, manner, '
      'and vocabulary a wise fortune teller would use. Do not write any explanations. '
      'You will act like you know all and see all about the future.');

  GeminiService(this.apiKey) {
    serviceModel = GenerativeModel(
      model: model,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
          maxOutputTokens: 100, temperature: 0.5, candidateCount: 1),
      systemInstruction: systemMessage,
    );
  }

  Stream<GenerateContentResponse> getFortune(String question) {
    final userMessage = Content.text(question);

    final chat = serviceModel.startChat();
    return chat.sendMessageStream(userMessage);
  }
}
