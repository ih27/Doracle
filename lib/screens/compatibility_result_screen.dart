import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../config/dependency_injection.dart';
import '../config/theme.dart';
import '../helpers/list_space_divider.dart';
import '../services/compatibility_guesser_service.dart';

class CompatibilityResultScreen extends StatefulWidget {
  final dynamic entity1;
  final dynamic entity2;

  const CompatibilityResultScreen({
    super.key,
    required this.entity1,
    required this.entity2,
  });

  @override
  _CompatibilityResultScreenState createState() =>
      _CompatibilityResultScreenState();
}

class _CompatibilityResultScreenState extends State<CompatibilityResultScreen> {
  final CompatibilityGuesser _compatibilityGuesser =
      getIt<CompatibilityGuesser>();
  Map<String, dynamic> _compatibilityResult = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompatibility();
  }

  Future<void> _fetchCompatibility() async {
    try {
      final result = await _compatibilityGuesser.getCompatibility(
          widget.entity1, widget.entity2);
      setState(() {
        _compatibilityResult = result;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      debugPrint('Error fetching compatibility: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Align(
        alignment: AlignmentDirectional.topCenter,
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildOverallCompatibility(context),
                _buildCompatibilityScores(context),
                _buildAstrologicalCompatibility(context),
                _buildPersonalizedRecommendations(context),
                _buildImprovementPlan(context),
              ].divide(height: 10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallCompatibility(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CircularPercentIndicator(
              percent: _compatibilityResult['overall'] ?? 0,
              radius: 60,
              lineWidth: 20,
              animation: true,
              animateFromLastPercent: true,
              progressColor: AppTheme.secondaryColor,
              backgroundColor: AppTheme.alternateColor,
              center: Text(
                '${((_compatibilityResult['overall'] ?? 0) * 100).toInt()}%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          Text(
            _compatibilityResult['astrology'] ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 20,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityScores(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScoreColumn(context, 'Temperament\nScore',
            _compatibilityResult['temperament'] ?? 0, AppTheme.naplesYellow),
        _buildScoreColumn(context, 'Exercise\nScore',
            _compatibilityResult['exercise'] ?? 0, AppTheme.sandyBrown),
        _buildScoreColumn(context, 'Care\nScore',
            _compatibilityResult['care'] ?? 0, AppTheme.tomato),
      ],
    );
  }

  Widget _buildScoreColumn(
      BuildContext context, String label, double percent, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CircularPercentIndicator(
            percent: percent,
            radius: 45,
            lineWidth: 15,
            animation: true,
            animateFromLastPercent: true,
            progressColor: color,
            backgroundColor: AppTheme.alternateColor,
            center: Text(
              '${(percent * 100).toInt()}%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompatibilitySection(
      BuildContext context, String title, String subtitle, String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          color: AppTheme.alternateColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.accent1,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    title,
                    minFontSize: 20,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 25,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  AutoSizeText(
                    subtitle,
                    minFontSize: 20,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 25,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 180,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      alignment: AlignmentDirectional.bottomCenter,
                      image: AssetImage(imagePath),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAstrologicalCompatibility(BuildContext context) {
    return _buildCompatibilitySection(
      context,
      'Astrological',
      'Compatibility',
      'assets/images/owner_pet_02.png',
    );
  }

  Widget _buildPersonalizedRecommendations(BuildContext context) {
    return _buildCompatibilitySection(
      context,
      'Personalized',
      'Recommendations',
      'assets/images/owner_pet_03.png',
    );
  }

  Widget _buildImprovementPlan(BuildContext context) {
    return _buildCompatibilitySection(
      context,
      '7-Day Compatibility',
      'Improvement Plan',
      'assets/images/owner_pet_04.png',
    );
  }
}
