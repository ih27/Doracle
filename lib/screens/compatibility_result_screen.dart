import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../config/dependency_injection.dart';
import '../config/theme.dart';
import '../helpers/compatibility_utils.dart';
import '../helpers/list_space_divider.dart';
import '../helpers/constants.dart';
import '../helpers/show_snackbar.dart';
import '../models/owner_model.dart';
import '../repositories/compatibility_data_repository.dart';
import '../services/compatibility_guesser_service.dart';
import '../models/pet_model.dart';

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

  final CompatibilityDataRepository _compatibilityDataRepository =
      getIt<CompatibilityDataRepository>();
  Map<String, dynamic> _compatibilityResult = {};
  bool _isLoading = true;
  Map<String, bool> _isCardDataAvailable = {
    CompatibilityTexts.astrologyCardId: false,
    CompatibilityTexts.recommendationCardId: false,
    CompatibilityTexts.improvementCardId: false,
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _fetchScores();
    await _checkLastCompatibilityCheck();
    await _loadCardAvailability();
    if (!_isCardDataAvailable[CompatibilityTexts.astrologyCardId]!) {
      _fetchAstrology();
    }
    if (!_isCardDataAvailable[CompatibilityTexts.recommendationCardId]!) {
      _fetchRecommendations();
    }
    if (!_isCardDataAvailable[CompatibilityTexts.improvementCardId]!) {
      _fetchImprovementPlan();
    }
  }

  Future<void> _checkLastCompatibilityCheck() async {
    String currentPlanId =
        generateConsistentPlanId(widget.entity1, widget.entity2);

    // Try to load existing data for the current check
    final existingPlan =
        await _compatibilityDataRepository.loadImprovementPlan(currentPlanId);

    if (existingPlan.isNotEmpty) {
      // Data exists for this check, load it
      await _loadSavedData(currentPlanId);
    } else {
      // No existing data, reset the card availability
      setState(() {
        _isCardDataAvailable = {
          CompatibilityTexts.astrologyCardId: false,
          CompatibilityTexts.recommendationCardId: false,
          CompatibilityTexts.improvementCardId: false,
        };
      });
      await _saveCardAvailability();
    }

    // Save the current check as the last check
    await _compatibilityDataRepository
        .saveLastCompatibilityCheck(currentPlanId);
  }

  Future<void> _loadSavedData(String planId) async {
    final astrology = await _compatibilityDataRepository.loadAstrology(planId);
    final recommendations =
        await _compatibilityDataRepository.loadRecommendations(planId);
    final improvementPlan =
        await _compatibilityDataRepository.loadImprovementPlan(planId);

    setState(() {
      _isCardDataAvailable[CompatibilityTexts.astrologyCardId] =
          astrology != null;
      _isCardDataAvailable[CompatibilityTexts.recommendationCardId] =
          recommendations != null;
      _isCardDataAvailable[CompatibilityTexts.improvementCardId] =
          improvementPlan.isNotEmpty;
    });
    await _saveCardAvailability();
  }

  Future<void> _loadCardAvailability() async {
    final availability =
        await _compatibilityDataRepository.loadCardAvailability();
    setState(() {
      _isCardDataAvailable.addAll(availability);
    });
  }

  Future<void> _saveCardAvailability() async {
    await _compatibilityDataRepository
        .saveCardAvailability(_isCardDataAvailable);
  }

  void _fetchScores() {
    try {
      final result = widget.entity2 is Owner
          ? _compatibilityGuesser.getPetOwnerScores(
              widget.entity1 as Pet, widget.entity2 as Owner)
          : _compatibilityGuesser.getPetPetScores(
              widget.entity1 as Pet, widget.entity2 as Pet);
      setState(() {
        _compatibilityResult = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching scores: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAstrology() async {
    String planId = generateConsistentPlanId(widget.entity1, widget.entity2);
    try {
      final result = await _compatibilityGuesser.getAstrologyCompatibility(
        widget.entity1,
        widget.entity2,
      );
      String astrologyJson = json.encode(result);
      await _compatibilityDataRepository.saveAstrology(planId, astrologyJson);
      setState(() {
        _isCardDataAvailable[CompatibilityTexts.astrologyCardId] = true;
      });
      await _saveCardAvailability();
    } catch (e) {
      debugPrint('Error fetching astrology: $e');
    }
  }

  Future<void> _fetchRecommendations() async {
    String planId = generateConsistentPlanId(widget.entity1, widget.entity2);
    try {
      final result = await _compatibilityGuesser.getRecommendations(
        widget.entity1,
        widget.entity2,
      );
      String recommendationsJson = json.encode(result);
      await _compatibilityDataRepository.saveRecommendations(
          planId, recommendationsJson);
      setState(() {
        _isCardDataAvailable[CompatibilityTexts.recommendationCardId] = true;
      });
      await _saveCardAvailability();
    } catch (e) {
      debugPrint('Error fetching recommendations: $e');
    }
  }

  Future<void> _fetchImprovementPlan() async {
    String planId = generateConsistentPlanId(widget.entity1, widget.entity2);

    // Check if the plan already exists
    bool exists = await _compatibilityDataRepository.planExists(planId);

    if (!exists) {
      try {
        final plan = await _compatibilityGuesser.getImprovementPlan(
            widget.entity1, widget.entity2);

        if (!plan.containsKey('error')) {
          await _compatibilityDataRepository.saveImprovementPlan(
              planId, json.encode(plan), widget.entity1, widget.entity2);
          setState(() {
            _isCardDataAvailable[CompatibilityTexts.improvementCardId] = true;
          });
        } else {
          // Handle the error case
          debugPrint('Error in improvement plan: ${plan['error']}');
          if (mounted) {
            showErrorSnackBar(context,
                'Failed to generate improvement plan. Please try again later.');
          }
        }
      } catch (e) {
        debugPrint('Error fetching improvement plan: $e');
        if (mounted) {
          showErrorSnackBar(context,
              'An error occurred while generating the improvement plan.');
        }
      }
    } else {
      setState(() {
        _isCardDataAvailable[CompatibilityTexts.improvementCardId] = true;
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
                _buildOverallCompatibility(),
                _buildCompatibilityScores(),
                _buildAstrologicalCompatibility(),
                _buildPersonalizedRecommendations(),
                _buildImprovementPlan(),
              ].divide(height: 10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallCompatibility() {
    final overallPercent = _compatibilityResult['overall'] ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CircularPercentIndicator(
              percent: overallPercent,
              radius: 60,
              lineWidth: 20,
              animation: true,
              animateFromLastPercent: true,
              progressColor: getColorFor(overallPercent),
              backgroundColor: AppTheme.alternateColor,
              center: Text(
                '${(overallPercent * 100).toInt()}%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          Text(
            getLevelFor(overallPercent),
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

  Widget _buildCompatibilityScores() {
    final temperamentPercent = _compatibilityResult['temperament'] ?? 0;
    final playtimePercent = _compatibilityResult['playtime'] ?? 0;
    final lifestyleMatchPercent = _compatibilityResult['lifestyle'] ?? 0;
    final treatSharingPercent = _compatibilityResult['treatSharing'] ?? 0;
    final carePercent = _compatibilityResult['care'] ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScoreColumn('Temperament\nScore', temperamentPercent),
        widget.entity2 is Pet
            ? _buildScoreColumn('Playtime\nScore', playtimePercent)
            : _buildScoreColumn('Lifestyle\nMatch', lifestyleMatchPercent),
        widget.entity2 is Pet
            ? _buildScoreColumn('Treat\nSharing', treatSharingPercent)
            : _buildScoreColumn('Care\nScore', carePercent),
      ],
    );
  }

  Widget _buildScoreColumn(String label, double percent) {
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
            progressColor: getColorFor(percent),
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
    String cardId,
    String title,
    String subtitle,
    String imagePath, {
    Function(BuildContext)? customNavigation,
  }) {
    return GestureDetector(
      onTap: _isCardDataAvailable[cardId]!
          ? () {
              if (customNavigation != null) {
                customNavigation(context);
              } else {
                navigateToCardDetail(context, cardId);
              }
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Opacity(
          opacity: _isCardDataAvailable[cardId]! ? 1.0 : 0.5,
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
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 25,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      AutoSizeText(
                        subtitle,
                        minFontSize: 20,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
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
        ),
      ),
    );
  }

  Widget _buildAstrologicalCompatibility() {
    String cardTitle = CompatibilityTexts.astrologyCardTitle;
    String cardSubtitle = CompatibilityTexts.astrologyCardSubtitle;
    if (!_isCardDataAvailable[CompatibilityTexts.astrologyCardId]!) {
      cardTitle = CompatibilityTexts.astrologyCardLoadingTitle;
      cardSubtitle = CompatibilityTexts.astrologyCardLoadingSubtitle;
    }
    return _buildCompatibilitySection(
      CompatibilityTexts.astrologyCardId,
      cardTitle,
      cardSubtitle,
      _getCompatibilityImage('01'),
    );
  }

  Widget _buildPersonalizedRecommendations() {
    String cardTitle = CompatibilityTexts.recommendationCardTitle;
    String cardSubtitle = CompatibilityTexts.recommendationCardSubtitle;
    if (!_isCardDataAvailable[CompatibilityTexts.recommendationCardId]!) {
      cardTitle = CompatibilityTexts.recommendationCardLoadingTitle;
      cardSubtitle = CompatibilityTexts.recommendationCardLoadingSubtitle;
    }
    return _buildCompatibilitySection(
      CompatibilityTexts.recommendationCardId,
      cardTitle,
      cardSubtitle,
      _getCompatibilityImage('02'),
    );
  }

  Widget _buildImprovementPlan() {
    String cardTitle = CompatibilityTexts.improvementCardTitle;
    String cardSubtitle = CompatibilityTexts.improvementCardSubtitle;
    if (!_isCardDataAvailable[CompatibilityTexts.improvementCardId]!) {
      cardTitle = CompatibilityTexts.improvementCardLoadingTitle;
      cardSubtitle = CompatibilityTexts.improvementCardLoadingSubtitle;
    }

    return _buildCompatibilitySection(
      CompatibilityTexts.improvementCardId,
      cardTitle,
      cardSubtitle,
      _getCompatibilityImage('03'),
      customNavigation: (context) {
        String planId =
            generateConsistentPlanId(widget.entity1, widget.entity2);
        navigateToImprovementPlan(context, planId);
      },
    );
  }

  String _getCompatibilityImage(String baseImageName) {
    return widget.entity2 is Owner
        ? 'assets/images/owner_pet_$baseImageName.png'
        : 'assets/images/pet_pet_$baseImageName.png';
  }
}
