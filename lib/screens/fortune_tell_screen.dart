import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fortuntella/services/openai_service.dart';
import 'package:fortuntella/widgets/form_button.dart';

class FortuneTellScreen extends StatefulWidget {
  const FortuneTellScreen({super.key});

  @override
  _FortuneTellScreenState createState() => _FortuneTellScreenState();
}

class _FortuneTellScreenState extends State<FortuneTellScreen> {
  final TextEditingController _questionController = TextEditingController();
  late OpenAIService _openAIService;
  String _fortune = '';
  bool _isLoading = false;
  String _selectedFortuneTeller = 'OpenAI';
  final List<String> _fortuneTellers = ['OpenAI', 'Gemini'];

  @override
  void initState() {
    super.initState();
    _loadApiKeyAndInitializeService();
  }

  Future<void> _loadApiKeyAndInitializeService() async {
    await dotenv.load(fileName: ".env");
    String? apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey != null) {
      _openAIService = OpenAIService(apiKey);
    } else {
      setState(() {
        _fortune = 'API key not found. Please check your .env file.';
      });
    }
  }

  void _getFortune() async {
    setState(() {
      _isLoading = true;
      _fortune = '';
    });

    try {
      Stream completionStream =
          _openAIService.getFortune(_questionController.text);

      completionStream.listen(
        (streamChatCompletion) {
          setState(() {
            final deltaContent = streamChatCompletion.choices.first.delta.content;
            if (deltaContent != null) {
              for (var contentItem in deltaContent) {
                if (contentItem != null && contentItem.text != null) {
                  _fortune += contentItem.text!;
                }
              }
            }
          });
        },
        onDone: () {
          setState(() {
            _fortune += '🔮';
            _isLoading = false;
          });
        },
        onError: (error) {
          setState(() {
            _fortune = 'Unexpected error occurred. Error: $error';
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _fortune = 'Failed to fetch fortune. Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fortune Teller'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ask your question and get a fortune reading!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Choose your fortune teller:',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedFortuneTeller,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFortuneTeller = newValue!;
                      });
                    },
                    items: _fortuneTellers
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your Question',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FormButton(
              text: 'Get Fortune',
              onPressed: _getFortune,
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_fortune.isNotEmpty)
              Text(
                _fortune,
                style:
                    const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
