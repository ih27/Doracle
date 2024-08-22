import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../config/dependency_injection.dart';
import '../config/theme.dart';
import '../helpers/list_space_divider.dart';
import '../helpers/constants.dart';
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

  final CompatibilityDataRepository _sharedPrefsService =
      getIt<CompatibilityDataRepository>();
  Map<String, dynamic> _compatibilityResult = {};
  bool _isLoading = true;
  final _isCardDataAvailable = {
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
    final lastCheck = await _sharedPrefsService.loadLastCompatibilityCheck();
    if (lastCheck != null) {
      String entity1Id = widget.entity1 is Pet ? (widget.entity1 as Pet).id : (widget.entity1 as Owner).id;
      String entity2Id = widget.entity2 is Pet ? (widget.entity2 as Pet).id : (widget.entity2 as Owner).id;
      if (lastCheck['entity1'] == entity1Id && lastCheck['entity2'] == entity2Id) {
        // The last check was for the same entities, load the saved data
        _loadSavedData();
      } else {
        // Different entities, clear previous data
        await _sharedPrefsService.clearAll();
      }
    }
    // Save the current check
    await _sharedPrefsService.saveLastCompatibilityCheck(
      widget.entity1 is Pet ? (widget.entity1 as Pet).id : (widget.entity1 as Owner).id,
      widget.entity2 is Pet ? (widget.entity2 as Pet).id : (widget.entity2 as Owner).id,
    );
  }

  Future<void> _loadSavedData() async {
    final astrology = await _sharedPrefsService.loadAstrology();
    final recommendations = await _sharedPrefsService.loadRecommendations();
    final improvementPlan = await _sharedPrefsService.loadImprovementPlan();

    setState(() {
      _isCardDataAvailable[CompatibilityTexts.astrologyCardId] = astrology != null;
      _isCardDataAvailable[CompatibilityTexts.recommendationCardId] = recommendations != null;
      _isCardDataAvailable[CompatibilityTexts.improvementCardId] = improvementPlan != null;
    });
    await _saveCardAvailability();
  }

  Future<void> _loadCardAvailability() async {
    final availability = await _sharedPrefsService.loadCardAvailability();
    setState(() {
      _isCardDataAvailable.addAll(availability);
    });
  }

  Future<void> _saveCardAvailability() async {
    await _sharedPrefsService.saveCardAvailability(_isCardDataAvailable);
  }

  Future<void> _fetchScores() async {
    try {
      final result = widget.entity2 is Owner
          ? _compatibilityGuesser.getPetOwnerScores(
              widget.entity1 as Pet, widget.entity2 as Owner)
          : await _compatibilityGuesser.getPetPetScores(
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
    try {
      final result = await _compatibilityGuesser.getAstrologyCompatibility(
        widget.entity1,
        widget.entity2,
      );
      await _sharedPrefsService.saveAstrology(result);
      setState(() {
        _isCardDataAvailable[CompatibilityTexts.astrologyCardId] = true;
      });
      await _saveCardAvailability();
    } catch (e) {
      debugPrint('Error fetching astrology: $e');
    }
  }

  Future<void> _fetchRecommendations() async {
    try {
      final result = await _compatibilityGuesser.getRecommendations(
        widget.entity1,
        widget.entity2,
      );
      await _sharedPrefsService.saveRecommendations(result);
      setState(() {
        _isCardDataAvailable[CompatibilityTexts.recommendationCardId] = true;
      });
      await _saveCardAvailability();
    } catch (e) {
      debugPrint('Error fetching recommendations: $e');
    }
  }

  Future<void> _fetchImprovementPlan() async {
    try {
      final result = widget.entity2 is Owner
          ? await _compatibilityGuesser.getPetOwnerImprovementPlan(
              widget.entity1 as Pet, widget.entity2 as Owner)
          : await _compatibilityGuesser.getPetPetScores(
              widget.entity1 as Pet, widget.entity2 as Pet);
      await _sharedPrefsService
          .saveImprovementPlan(result as String); // TEMPORARY CAST
      setState(() {
        _isCardDataAvailable[CompatibilityTexts.improvementCardId] = true;
      });
      await _saveCardAvailability();
    } catch (e) {
      debugPrint('Error fetching improvement plan: $e');
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
              progressColor: _getColorFor(overallPercent),
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
            _getLevelFor(overallPercent),
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
            progressColor: _getColorFor(percent),
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
      String cardId, String title, String subtitle, String imagePath) {
    return GestureDetector(
      onTap: _isCardDataAvailable[cardId]!
          ? () => _navigateToCardDetail(cardId)
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
      'assets/images/owner_pet_02.png',
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
      'assets/images/owner_pet_03.png',
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
      'assets/images/owner_pet_04.png',
    );
  }

  void _navigateToCardDetail(String cardId) {
    Navigator.pushNamed(
      context,
      '/result/card',
      arguments: {'cardId': cardId},
    );
  }

  Color _getColorFor(double percent) {
    Color progressColor = AppTheme.tomato;
    final percentInt = (percent * 100).toInt();
    if (percentInt > 75) {
      progressColor = AppTheme.secondaryColor;
    } else if (percentInt > 50) {
      progressColor = AppTheme.naplesYellow;
    } else if (percentInt > 25) {
      progressColor = AppTheme.sandyBrown;
    }
    return progressColor;
  }

  String _getLevelFor(double percent) {
    String level = 'They\'re like oil and water!';
    final percentInt = (percent * 100).toInt();
    if (percentInt > 80) {
      level = 'They\'re very harmonious!';
    } else if (percentInt > 60) {
      level = 'They\'re a promising pair!';
    } else if (percentInt > 40) {
      level = 'They\'re finding their rhythm.';
    } else if (percentInt > 20) {
      level = 'There\'s room for improvement.';
    }
    return level;
  }
}
