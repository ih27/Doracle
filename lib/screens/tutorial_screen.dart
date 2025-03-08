import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;

import '../config/theme.dart';
import '../config/dependency_injection.dart';
import '../services/unified_analytics_service.dart';
import 'splash_screen.dart';

class TutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  const TutorialScreen(
      {super.key,
      required this.onComplete,
      required this.onSignIn,
      required this.onSignUp});

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  late TutorialScreenModel _model;
  final UnifiedAnalyticsService _analytics = getIt<UnifiedAnalyticsService>();

  final List<TutorialPageData> _pageData = [
    TutorialPageData(
      imagePath: 'assets/images/tuto01.png',
      title: 'Pet-Parent Compatibility Check',
      description:
          'Discover how well you and your pet\'s zodiac signs align, offering insights into your relationship and communication style.',
    ),
    TutorialPageData(
      imagePath: 'assets/images/tuto02.png',
      title: 'Multi-Pet Harmony Forecast',
      description:
          'Planning to add a new pet to your home? Check how well potential new additions will mesh with your current pets based on their astrological profiles.',
    ),
    TutorialPageData(
      imagePath: 'assets/images/tuto03.png',
      title: 'Daily Paw-roscopes',
      description:
          'Start each day with tailored horoscopes for both you and your pets, giving you a playful glimpse into what the stars have in store for your furry friends.',
    ),
    TutorialPageData(
      imagePath: 'assets/images/tuto04.png',
      title: 'The Dog Oracle',
      description:
          'The ultimate source of pet wisdom! Ask anything and receive enlightened answers about you and your pets.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _model = TutorialScreenModel();

    // Log screen view
    _analytics.logScreenView(screenName: 'tutorial_screen');
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.primaryBackground,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              PageView(
                controller: _model.pageViewController,
                scrollDirection: Axis.horizontal,
                children: [
                  ..._pageData.map((data) =>
                      TutorialPage(data: data, onNextPressed: _nextPage)),
                  _buildFinalPage(),
                ],
              ),
              Align(
                alignment: const AlignmentDirectional(-0.85, 0.85),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: smooth_page_indicator.SmoothPageIndicator(
                    controller: _model.pageViewController,
                    count: _pageData.length + 1,
                    axisDirection: Axis.horizontal,
                    onDotClicked: (i) async {
                      await _model.pageViewController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.ease,
                      );
                    },
                    effect: const smooth_page_indicator.ExpandingDotsEffect(
                      expansionFactor: 2,
                      spacing: 8,
                      radius: 16,
                      dotWidth: 16,
                      dotHeight: 4,
                      dotColor: AppTheme.accent1,
                      activeDotColor: AppTheme.secondaryColor,
                      paintStyle: PaintingStyle.fill,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextPage() {
    _model.pageViewController.nextPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  Widget _buildFinalPage() {
    return SplashScreen(
      onSignIn: widget.onSignIn,
      onSignUp: widget.onSignUp,
    );
  }
}

class TutorialPageData {
  final String imagePath;
  final String title;
  final String description;

  TutorialPageData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class TutorialPage extends StatelessWidget {
  final TutorialPageData data;
  final VoidCallback onNextPressed;

  const TutorialPage({
    super.key,
    required this.data,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Image.asset(
          data.imagePath,
          width: double.infinity,
          height: 500,
          fit: BoxFit.contain,
          alignment: const Alignment(0, 1),
        ).animate().fade(duration: 600.ms).scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(1.0, 1.0),
            duration: 600.ms),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 24,
                      letterSpacing: 0,
                    ),
              )
                  .animate()
                  .fade(duration: 600.ms)
                  .moveY(begin: 60, end: 0, duration: 600.ms),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  data.description,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        letterSpacing: 0,
                      ),
                )
                    .animate()
                    .fade(duration: 600.ms)
                    .moveY(begin: 80, end: 0, duration: 600.ms),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.navigate_next_rounded,
                        color: AppTheme.secondaryColor,
                        size: 30,
                      ),
                      onPressed: onNextPressed,
                    ).animate().fade(duration: 600.ms).scale(
                        begin: const Offset(0.4, 0.4),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TutorialScreenModel {
  PageController pageViewController = PageController();

  void dispose() {
    pageViewController.dispose();
  }
}
