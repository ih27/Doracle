import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey;
  String instructions;
  final String model = 'gemini-1.5-flash';
  late GenerativeModel serviceModel;

  GeminiService(this.apiKey, this.instructions) {
    _initializeModel();
  }

  void _initializeModel() {
    serviceModel = GenerativeModel(
      model: model,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
          maxOutputTokens: 100, temperature: 0.5, candidateCount: 1),
      systemInstruction: Content.system(instructions),
    );
  }

  void setInstructions(String newInstructions) {
    instructions = newInstructions;
    _initializeModel();
  }

  Stream<GenerateContentResponse> getFortune(String question) {
    final userMessage = Content.text(question);

    final chat = serviceModel.startChat();
    return chat.sendMessageStream(userMessage);
  }
}
