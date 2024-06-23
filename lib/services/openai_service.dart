import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenAIService {
  final String apiKey;
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  final String model = 'gpt-3.5-turbo';

  OpenAIService(this.apiKey);

  Future<String> getFortune(String question) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a wise fortune teller. Answer the following question in a mystical and insightful way.'
          },
          {'role': 'user', 'content': question}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to fetch fortune');
    }
  }
}
