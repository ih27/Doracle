import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import '../helpers/constants.dart';
import '../helpers/iap_utils.dart';
import '../repositories/compatibility_data_repository.dart';
import 'package:flutter/material.dart';
import '../config/dependency_injection.dart';
import '../config/theme.dart';
import '../services/revenuecat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_expansion_panel_list.dart';

class CompatibilityResultCardScreen extends StatefulWidget {
  final String cardId;
  final String planId;

  const CompatibilityResultCardScreen(
      {super.key, required this.cardId, required this.planId});

  @override
  _CompatibilityResultCardScreenState createState() =>
      _CompatibilityResultCardScreenState();
}

class _CompatibilityResultCardScreenState
    extends State<CompatibilityResultCardScreen> {
  final RevenueCatService _purchaseService = getIt<RevenueCatService>();
  final UserService _userService = getIt<UserService>();
  final CompatibilityDataRepository _compatibilityDataRepository =
      getIt<CompatibilityDataRepository>();
  late List<bool> _isExpanded;
  Map<String, String> _cachedPrices = {};
  bool _isEntitled = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = List.generate(4, (_) => false);
    _fetchPricesIfNeeded();
    _isEntitled = _purchaseService.isEntitled;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.cardId == CompatibilityTexts.astrologyCardId
          ? _loadAstrologyData()
          : _loadRecommendationsData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        List<CustomExpansionPanel> expansionPanels =
            widget.cardId == CompatibilityTexts.astrologyCardId
                ? _buildAstrologyCards(snapshot.data!)
                : _buildRecommendationCards(snapshot.data!);

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
                child: CustomExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    if (_isEntitled) {
                      setState(() {
                        _isExpanded[index] = !_isExpanded[index];
                      });
                    }
                  },
                  onNonExpandableTap: _isEntitled ? null : _showIAPOverlay,
                  children: expansionPanels,
                ),
              ),
              const SizedBox(height: 25),
              if (!_isEntitled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 160,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _purchaseButton(),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 275,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Detailed compatibility reports.',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              Text('In-depth practical compatibility analysis.',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              Text(
                                  'Comprehensive astrological compatibility breakdown.',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<CustomExpansionPanel> _buildAstrologyCards(
      Map<String, dynamic> astrologyData) {
    List<String> cardKeys = [
      'elementalHarmony',
      'planetaryInfluence',
      'sunSignCompatibility',
      'moonSignSynergy'
    ];

    return cardKeys.map((key) {
      var cardData = astrologyData[key];
      return _buildCustomExpansionPanel(
        cardKeys.indexOf(key),
        cardData['title'],
        cardData['content'].split('.').first,
        cardData['content'],
      );
    }).toList();
  }

  List<CustomExpansionPanel> _buildRecommendationCards(
      Map<String, dynamic> recommendationsData) {
    List<CustomExpansionPanel> cards = [];

    // Add practical recommendations
    for (int i = 0; i < 5; i++) {
      var recData = recommendationsData['practicalRecommendations'][i];
      cards.add(_buildCustomExpansionPanel(
        i,
        'Recommendation ${i + 1}',
        recData.split('.').first,
        recData,
      ));
    }

    // Add astrological bonus tip
    var bonusTip = recommendationsData['astrologicalBonusTip'];
    cards.add(_buildCustomExpansionPanel(
      5,
      'Astrological Bonus Tip',
      bonusTip.split('.').first,
      bonusTip,
    ));

    return cards;
  }

  CustomExpansionPanel _buildCustomExpansionPanel(
    int index,
    String header,
    String summary,
    String details,
  ) {
    return CustomExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return Container(
          color:
              isExpanded ? AppTheme.lemonChiffon : AppTheme.primaryBackground,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                header,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                maxFontSize: 24,
              ),
              if (!isExpanded)
                AutoSizeText(
                  summary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        );
      },
      body: Container(
        color: AppTheme.lemonChiffon,
        padding: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width,
        child: Text(
          details,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.primaryColor,
              ),
        ),
      ),
      isExpanded: _isExpanded[index % _isExpanded.length],
    );
  }

  Future<Map<String, dynamic>> _loadAstrologyData() async {
    final String? astrologyJson =
        await _compatibilityDataRepository.loadAstrology(widget.planId);
    if (astrologyJson != null) {
      // Decode twice to handle the escaped JSON string
      final decodedOnce = json.decode(astrologyJson);
      final decodedTwice = json.decode(decodedOnce);
      return decodedTwice;
    }
    return {};
  }

  Future<Map<String, dynamic>> _loadRecommendationsData() async {
    final String? recommendationsJson =
        await _compatibilityDataRepository.loadRecommendations(widget.planId);
    if (recommendationsJson != null) {
      return json.decode(recommendationsJson);
    }
    return {};
  }

  Widget _purchaseButton() {
    return GestureDetector(
      onTap: _showIAPOverlay,
      child: Material(
        color: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: 250,
          height: 50,
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: AppTheme.secondaryColor,
                offset: Offset(0, 2),
              )
            ],
            gradient: const LinearGradient(
              colors: [AppTheme.secondaryColor, AppTheme.yaleBlue],
              stops: [0, 1],
              begin: AlignmentDirectional(0, -1),
              end: AlignmentDirectional(0, 1),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: const AlignmentDirectional(0, 0),
          child: Text(
            'Go deeper+',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.secondaryBackground,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchPricesIfNeeded() async {
    final updatedPrices = await IAPUtils.fetchSubscriptionPrices(_cachedPrices);
    setState(() {
      _cachedPrices = updatedPrices;
    });
  }

  void _showIAPOverlay() {
    IAPUtils.showIAPOverlay(context, _cachedPrices, _handlePurchase);
  }

  Future<void> _handlePurchase(String subscriptionType) async {
    bool success = await IAPUtils.handlePurchase(context, subscriptionType);
    if (success) {
      await _userService.updateSubscriptionHistory(subscriptionType);
      setState(() {
        _isEntitled = true;
      });
    }
  }
}
