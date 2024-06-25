import 'package:flutter/material.dart';
import 'package:fortuntella/controllers/fortune_teller.dart';
import 'package:fortuntella/controllers/openai_fortune_teller.dart';
import 'package:fortuntella/controllers/gemini_fortune_teller.dart';
import 'package:fortuntella/widgets/form_button.dart';

class FortuneTellScreen extends StatefulWidget {
  const FortuneTellScreen({super.key});

  @override
  _FortuneTellScreenState createState() => _FortuneTellScreenState();
}

class _FortuneTellScreenState extends State<FortuneTellScreen> {
  final TextEditingController _questionController = TextEditingController();
  FortuneTeller? _fortuneTeller;
  List<String> _fortuneParts = [];
  bool _isLoading = false;
  String _selectedFortuneTeller = 'OpenAI';
  final List<String> _fortuneTellers = ['OpenAI', 'Gemini'];

  @override
  void initState() {
    super.initState();
    _initializeFortuneTeller();
  }

  void _initializeFortuneTeller() {
    if (_selectedFortuneTeller == 'OpenAI') {
      _fortuneTeller = OpenAIFortuneTeller();
    } else {
      _fortuneTeller = GeminiFortuneTeller();
    }
  }

  void _getFortune() {
    setState(() {
      _isLoading = true;
      _fortuneParts = [];
    });

    try {
      if (_fortuneTeller != null) {
        _fortuneTeller!.getFortune(_questionController.text).listen(
          (fortunePart) {
            setState(() {
              _fortuneParts.add(fortunePart);
            });
          },
          onDone: () {
            setState(() {
              _fortuneParts.add('🔮');
              _isLoading = false;
            });
          },
          onError: (error) {
            setState(() {
              _fortuneParts.add('Unexpected error occurred. Error: $error');
              _isLoading = false;
            });
          },
        );
      } else {
        setState(() {
          _fortuneParts.add('No fortune teller selected.');
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _fortuneParts.add('Failed to fetch fortune. Error: $e');
        _isLoading = false;
      });
    }
  }

  void _onFortuneTellerChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedFortuneTeller = newValue;
        _initializeFortuneTeller();
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
                const Text('Choose your fortune teller:'),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedFortuneTeller,
                    onChanged: _onFortuneTellerChanged,
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
            if (_isLoading) const CircularProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemCount: _fortuneParts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      _fortuneParts[index],
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
