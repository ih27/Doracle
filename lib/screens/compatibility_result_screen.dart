import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../config/dependency_injection.dart';
import '../config/theme.dart';
import '../helpers/compatibility_utils.dart';
import '../helpers/iap_utils.dart';
import '../helpers/list_space_divider.dart';
import '../helpers/constants.dart';
import '../helpers/show_snackbar.dart';
import '../models/owner_model.dart';
import '../models/pet_model.dart';
import '../providers/entitlement_provider.dart';
import '../repositories/compatibility_data_repository.dart';
import '../services/compatibility_content_service.dart';
import '../services/compatibility_score_service.dart';
import '../services/user_service.dart';
import '../services/unified_analytics_service.dart';

class CompatibilityResultScreen extends StatefulWidget {
  final dynamic entity1;
  final dynamic entity2;
  final Map<String, dynamic>? scores;

  const CompatibilityResultScreen({
    super.key,
    required this.entity1,
    required this.entity2,
    this.scores,
  });

  @override
  _CompatibilityResultScreenState createState() =>
      _CompatibilityResultScreenState();
}

class _CompatibilityResultScreenState extends State<CompatibilityResultScreen> {
  final CompatibilityScoreService _compatibilityScoreService =
      getIt<CompatibilityScoreService>();
  final CompatibilityContentService _compatibilityContentService =
      getIt<CompatibilityContentService>();
  final CompatibilityDataRepository _compatibilityDataRepository =
      getIt<CompatibilityDataRepository>();
  final UserService _userService = getIt<UserService>();
  final UnifiedAnalyticsService _analytics = getIt<UnifiedAnalyticsService>();

  Map<String, dynamic> _compatibilityResult = {};
  bool _isLoading = true;
  Map<String, String> _cachedPrices = {};
  bool _planWasOpenedBefore = false;
  Map<String, bool> _isCardDataAvailable = {
    CompatibilityTexts.astrologyCardId: false,
    CompatibilityTexts.recommendationCardId: false,
    CompatibilityTexts.improvementCardId: false,
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchPricesIfNeeded();
    _checkPlanStatus();
    _analytics.logScreenView(screenName: 'compatibility_result_screen');
  }

  Future<void> _checkPlanStatus() async {
    String planId = generateConsistentPlanId(widget.entity1, widget.entity2);
    _planWasOpenedBefore =
        await _compatibilityDataRepository.planWasOpened(planId);
  }

  Future<void> _initializeData() async {
    if (widget.scores != null) {
      setState(() {
        _compatibilityResult = widget.scores!;
        _isLoading = false;
      });
    } else {
      _fetchScores();
    }
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

  Future<void> _fetchScores() async {
    try {
      final result = widget.entity2 is Owner
          ? _compatibilityScoreService.getPetOwnerScores(
              widget.entity1 as Pet, widget.entity2 as Owner)
          : _compatibilityScoreService.getPetPetScores(
              widget.entity1 as Pet, widget.entity2 as Pet);
      setState(() {
        _compatibilityResult = result;
        _isLoading = false;
      });
      // Save the compatibility score
      await _saveCompatibilityScore(result);
    } catch (e) {
      // Error occurred while fetching scores
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCompatibilityScore(Map<String, dynamic> scores) async {
    try {
      await _compatibilityDataRepository.saveCompatibilityScore(
          widget.entity1, widget.entity2, scores);
    } catch (e) {
      // Error occurred while saving compatibility score
    }
  }

  Future<void> _fetchAstrology() async {
    String planId = generateConsistentPlanId(widget.entity1, widget.entity2);
    try {
      final result =
          await _compatibilityContentService.getAstrologyCompatibility(
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
      // Error occurred while fetching astrology
    }
  }

  Future<void> _fetchRecommendations() async {
    String planId = generateConsistentPlanId(widget.entity1, widget.entity2);
    try {
      final result = await _compatibilityContentService.getRecommendations(
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
      // Error occurred while fetching recommendations
    }
  }

  Future<void> _fetchImprovementPlan() async {
    String planId = generateConsistentPlanId(widget.entity1, widget.entity2);

    // Check if the plan already exists
    bool exists = await _compatibilityDataRepository.planExists(planId);

    if (!exists) {
      try {
        final plan = await _compatibilityContentService.getImprovementPlan(
            widget.entity1, widget.entity2);

        if (!plan.containsKey('error')) {
          await _compatibilityDataRepository.saveImprovementPlan(
              planId, json.encode(plan), widget.entity1, widget.entity2);
          setState(() {
            _isCardDataAvailable[CompatibilityTexts.improvementCardId] = true;
          });
        } else {
          if (mounted) {
            showErrorSnackBar(context,
                'Failed to generate improvement plan. Please try again later.');
          }
        }
      } catch (e) {
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
    return Consumer<EntitlementProvider>(
      builder: (context, entitlementProvider, child) {
        if (_isLoading) {
          return const Center(
              child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ));
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
                    _buildAstrologicalCompatibility(entitlementProvider),
                    _buildPersonalizedRecommendations(entitlementProvider),
                    _buildImprovementPlan(entitlementProvider),
                  ].divide(height: 10),
                ),
              ),
            ),
          ),
        );
      },
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
            getLevelFor(overallPercent, widget.entity2 is Owner),
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
    bool? locked,
  }) {
    String planId = generateConsistentPlanId(widget.entity1, widget.entity2);
    return GestureDetector(
      onTap: _isCardDataAvailable[cardId]!
          ? () {
              if (customNavigation != null) {
                customNavigation(context);
              } else if (locked != null && locked) {
                _showIAPOverlay(context, cardId);
              } else {
                _compatibilityDataRepository.markPlanAsOpened(planId);
                navigateToCardDetail(context, cardId, planId);
              }
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Opacity(
          opacity: _isCardDataAvailable[cardId]! ? 1.0 : 0.5,
          child: Stack(
            children: [
              Container(
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
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontSize: 25,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          AutoSizeText(
                            subtitle,
                            minFontSize: 20,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
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
              if (locked != null && locked)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.alternateColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock,
                        color: AppTheme.primaryColor, size: 20),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAstrologicalCompatibility(
      EntitlementProvider entitlementProvider) {
    String cardTitle = CompatibilityTexts.astrologyCardTitle;
    String cardSubtitle = CompatibilityTexts.astrologyCardSubtitle;
    String cardId = CompatibilityTexts.astrologyCardId;
    if (!_isCardDataAvailable[cardId]!) {
      cardTitle = CompatibilityTexts.astrologyCardLoadingTitle;
      cardSubtitle = CompatibilityTexts.astrologyCardLoadingSubtitle;
    }

    final locked = !entitlementProvider.isEntitled && !_planWasOpenedBefore;

    return _buildCompatibilitySection(
      cardId,
      cardTitle,
      cardSubtitle,
      _getCompatibilityImage('01'),
      locked: locked,
    );
  }

  Widget _buildPersonalizedRecommendations(
      EntitlementProvider entitlementProvider) {
    String cardTitle = CompatibilityTexts.recommendationCardTitle;
    String cardSubtitle = CompatibilityTexts.recommendationCardSubtitle;
    String cardId = CompatibilityTexts.recommendationCardId;
    if (!_isCardDataAvailable[cardId]!) {
      cardTitle = CompatibilityTexts.recommendationCardLoadingTitle;
      cardSubtitle = CompatibilityTexts.recommendationCardLoadingSubtitle;
    }

    final locked = !entitlementProvider.isEntitled && !_planWasOpenedBefore;

    return _buildCompatibilitySection(
      cardId,
      cardTitle,
      cardSubtitle,
      _getCompatibilityImage('02'),
      locked: locked,
    );
  }

  Widget _buildImprovementPlan(EntitlementProvider entitlementProvider) {
    String cardTitle = CompatibilityTexts.improvementCardTitle;
    String cardSubtitle = CompatibilityTexts.improvementCardSubtitle;
    String cardId = CompatibilityTexts.improvementCardId;
    if (!_isCardDataAvailable[cardId]!) {
      cardTitle = CompatibilityTexts.improvementCardLoadingTitle;
      cardSubtitle = CompatibilityTexts.improvementCardLoadingSubtitle;
    }

    final locked = !entitlementProvider.isEntitled && !_planWasOpenedBefore;

    return _buildCompatibilitySection(
      cardId,
      cardTitle,
      cardSubtitle,
      _getCompatibilityImage('03'),
      customNavigation: (context) {
        if (locked) {
          _showIAPOverlay(context, cardId);
        } else {
          String planId =
              generateConsistentPlanId(widget.entity1, widget.entity2);
          _compatibilityDataRepository.markPlanAsOpened(planId);
          navigateToImprovementPlan(context, planId);
        }
      },
      locked: locked,
    );
  }

  Future<void> _fetchPricesIfNeeded() async {
    final updatedPrices = await IAPUtils.fetchSubscriptionPrices(_cachedPrices);
    setState(() {
      _cachedPrices = updatedPrices;
    });
  }

  void _showIAPOverlay(BuildContext overlayContext, String cardId) {
    IAPUtils.showIAPOverlay(overlayContext, _cachedPrices,
        (subscriptionType) => _handlePurchase(subscriptionType, cardId));
  }

  Future<void> _handlePurchase(String subscriptionType, String cardId) async {
    bool success = await IAPUtils.handlePurchase(context, subscriptionType);
    if (success) {
      await _userService.updateSubscriptionHistory(subscriptionType);

      // Mark the plan as opened
      String planId = generateConsistentPlanId(widget.entity1, widget.entity2);
      await _compatibilityDataRepository.markPlanAsOpened(planId);

      if (mounted) {
        if (cardId == CompatibilityTexts.improvementCardId) {
          navigateToImprovementPlan(context, planId);
        } else {
          navigateToCardDetail(context, cardId, planId);
        }
      }
    }
  }

  String _getCompatibilityImage(String baseImageName) {
    return widget.entity2 is Owner
        ? 'assets/images/owner_pet_$baseImageName.png'
        : 'assets/images/pet_pet_$baseImageName.png';
  }
}
