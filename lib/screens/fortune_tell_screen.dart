import 'package:flutter/material.dart';
import '../controllers/fortune_teller.dart';
import '../dependency_injection.dart';
import '../helpers/show_snackbar.dart';
import '../repositories/fortune_content_repository.dart';
import '../widgets/form_button.dart';

class FortuneTellScreen extends StatefulWidget {
  const FortuneTellScreen({super.key});

  @override
  _FortuneTellScreenState createState() => _FortuneTellScreenState();
}

class _FortuneTellScreenState extends State<FortuneTellScreen> {
  final FortuneContentRepository _fortuneContentRepository =
      getIt<FortuneContentRepository>();
  late Future<void> _initializationFuture;

  final TextEditingController _questionController = TextEditingController();
  List<TextSpan> _fortuneSpans = [];
  bool _isLoading = false;
  bool _isFortuneCompleted = false;
  List<String> _randomQuestions = [];
  final int _numberOfQuestionsPerCategory = 2;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      _initializeFortuneTeller(),
      _fetchRandomQuestions(),
    ]);
  }

  Future<void> _initializeFortuneTeller() async {
    final personaData = await _fortuneContentRepository.getRandomPersona();
    setFortuneTellerPersona(
      personaData['name']!,
      personaData['instructions']!,
    );
  }

  Future<void> _fetchRandomQuestions() async {
    final randomQuestions = await _fortuneContentRepository
        .fetchRandomQuestions(_numberOfQuestionsPerCategory);
    setState(() {
      _randomQuestions = randomQuestions;
    });
  }

  void _getFortune(String question) async {
    if (question.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter a question.');
      return;
    }

    setState(() {
      _isLoading = true;
      _isFortuneCompleted = false;
      _fortuneSpans = [];
    });

    try {
      await _initializeFortuneTeller(); // Ensure initialization is complete
      final fortuneTeller = getIt<FortuneTeller>();
      fortuneTeller.getFortune(question).listen(
        (fortunePart) {
          setState(() {
            _fortuneSpans = List.from(_fortuneSpans)
              ..add(TextSpan(text: fortunePart));
          });
        },
        onDone: () {
          setState(() {
            _fortuneSpans = List.from(_fortuneSpans)
              ..add(const TextSpan(text: '🔮'));
            _isLoading = false;
            _isFortuneCompleted = true;
          });
        },
        onError: (error) {
          setState(() {
            _fortuneSpans = List.from(_fortuneSpans)
              ..add(const TextSpan(text: 'Unexpected error occurred'));
            _isLoading = false;
            _isFortuneCompleted = true;
          });
        },
      );
    } catch (e) {
      setState(() {
        print(e);
        _fortuneSpans = List.from(_fortuneSpans)
          ..add(const TextSpan(text: 'Our puppy is not in the mood...'));
        _isLoading = false;
        _isFortuneCompleted = true;
      });
    }
  }

  void _onQuestionSelected(String question) {
    _getFortune(question);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return _fortuneSpans.isEmpty ? _buildInitialScreen() : _buildAnswerScreen();
        }
      },
    );
  }

  Widget _buildInitialScreen() {
    return Padding(
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
            onPressed: () => _getFortune(_questionController.text),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _randomQuestions.length,
              itemBuilder: (context, index) {
                return Center(
                  child: IntrinsicWidth(
                    child: GestureDetector(
                      onTap: () => _onQuestionSelected(_randomQuestions[index]),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(_randomQuestions[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildAnswerScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: RichText(
                text: TextSpan(
                  children: _fortuneSpans,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.normal,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_isFortuneCompleted)
            FormButton(
              text: 'Continue',
              onPressed: () {
                setState(() {
                  _questionController.clear();
                  _fortuneSpans = [];
                  _isFortuneCompleted = false;
                  _fetchRandomQuestions();
                });
              },
            ),
        ],
      ),
    );
  }
}
