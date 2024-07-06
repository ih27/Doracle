import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fortuntella/mixins/shake_detector.dart';
import 'package:fortuntella/services/user_service.dart';
import 'package:rive/rive.dart';
import '../controllers/fortune_teller.dart';
import '../dependency_injection.dart';
import '../helpers/show_snackbar.dart';
import '../repositories/fortune_content_repository.dart';
import '../theme.dart';

class FortuneTellScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final VoidCallback onFeedDog;

  const FortuneTellScreen(
      {super.key, required this.onNavigate, required this.onFeedDog});

  @override
  _FortuneTellScreenState createState() => _FortuneTellScreenState();
}

class _FortuneTellScreenState extends State<FortuneTellScreen>
    with ShakeDetectorMixin {
  final FortuneContentRepository _fortuneContentRepository =
      getIt<FortuneContentRepository>();
  final UserService _userService = getIt<UserService>();
  late Future<void> _initializationFuture;

  final TextEditingController _questionController = TextEditingController();
  List<TextSpan> _fortuneSpans = [];
  bool _isLoading = false;
  bool _isFortuneCompleted = false;
  List<String> _randomQuestions = [];
  final int _numberOfQuestionsPerCategory = 2;
  final double _inputFieldFixedHeight = 66;
  late int _startingCount;
  late int _remainingQuestions;

  SMITrigger? _shakeInput;

  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
    artboard.addController(controller!);
    _shakeInput = controller.findInput<bool>('Shake') as SMITrigger;
  }

  void _shake() {
    _shakeInput?.fire();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initialize();
    initShakeDetector(onShake: () => _shake());
  }

  Future<void> _initialize() async {
    await Future.wait([
      _initializeFortuneTeller(),
      _fetchRandomQuestions(),
      _fetchStartingCount(),
    ]);
  }

  Future<void> _fetchStartingCount() async {
    _startingCount = await _fortuneContentRepository.getStartingCount();
    await _updateRemainingQuestions();
  }

  Future<void> _updateRemainingQuestions() async {
    final questionsAsked =
        await _userService.getUserField<int>('questionsAsked') ?? 0;
    setState(() {
      _remainingQuestions = _startingCount - questionsAsked;
    });
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
      await _initializeFortuneTeller();
      final fortuneTeller = getIt<FortuneTeller>();
      bool isFirstChunk = true;
      fortuneTeller.getFortune(question).listen(
        (fortunePart) {
          setState(() {
            if (isFirstChunk) {
              _isLoading = false;
              isFirstChunk = false;
            }
            _fortuneSpans = List.from(_fortuneSpans)
              ..add(TextSpan(text: fortunePart));
          });
        },
        onDone: () async {
          await _updateRemainingQuestions();
          setState(() {
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
    return SafeArea(
        child: FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return GestureDetector(
            onTap: _dismissKeyboard,
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildRiveAnimation(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _fortuneSpans.isEmpty
                            ? _buildQuestionSection()
                            : _buildAnswerSection(),
                      ),
                    ),
                  ],
                ),
                if (_isLoading) _buildLoadingOverlay(),
              ],
            ),
          );
        }
      },
    ));
  }

  Widget _buildRiveAnimation() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.width * 0.7,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: RiveAnimation.asset(
        'assets/animations/meraki_dog.riv',
        artboard: 'meraki_dog',
        fit: BoxFit.contain,
        onInit: _onRiveInit,
      ),
    );
  }

  Widget _buildQuestionSection() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final mediaQuery = MediaQuery.of(context);
        final bottomPadding = mediaQuery.padding.bottom;
        final bottomInset = mediaQuery.viewInsets.bottom;
        final isKeyboardVisible = bottomInset > 0;

        return NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[];
          },
          body: Stack(
            children: [
              SizedBox(
                height: constraints.maxHeight -
                    _inputFieldFixedHeight -
                    bottomPadding,
                child: _buildCarousel(),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                bottom: isKeyboardVisible ? bottomInset : bottomPadding,
                child: _buildQuestionInput(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider.builder(
      itemCount: _randomQuestions.length,
      itemBuilder: (context, index, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ElevatedButton(
            onPressed: _remainingQuestions > 0
                ? () {
                    _dismissKeyboard();
                    _onQuestionSelected(_randomQuestions[index]);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              _randomQuestions[index],
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: double.infinity,
        viewportFraction: 0.2,
        enableInfiniteScroll: true,
        scrollDirection: Axis.vertical,
        enlargeCenterPage: true,
        enlargeFactor: 0.25,
      ),
    );
  }

  Widget _buildQuestionInput() {
    return Container(
      height: _inputFieldFixedHeight,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _remainingQuestions > 0 ? null : widget.onFeedDog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent1,
                //foregroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.zero,
                minimumSize: const Size(35, 35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              child: Text(
                '$_remainingQuestions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _remainingQuestions > 0
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: TextField(
                controller: _questionController,
                enabled: _remainingQuestions > 0,
                decoration: InputDecoration(
                  labelText: 'Ask what you want, passenger?',
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              icon: Icon(Icons.send_rounded,
                  color: Theme.of(context).primaryColor),
              onPressed: _remainingQuestions > 0
                  ? () {
                      _dismissKeyboard();
                      _getFortune(_questionController.text);
                    }
                  : null,
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.accent1,
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSection() {
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SelectionArea(
                    child: RichText(
                      text: TextSpan(
                        children: _fortuneSpans,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFamily: 'Roboto Mono',
                              fontSize: 15,
                              letterSpacing: 0,
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isFortuneCompleted)
          Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _questionController.clear();
                  _fortuneSpans = [];
                  _isFortuneCompleted = false;
                  _fetchRandomQuestions();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 3,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Continue',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontFamily: 'Roboto',
                      color: Colors.white,
                      letterSpacing: 0,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.25),
      child: Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
