import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import '../helpers/constants.dart';
import '../repositories/compatibility_data_repository.dart';
import 'package:flutter/material.dart';
import '../config/dependency_injection.dart';
import '../config/theme.dart';
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
  final CompatibilityDataRepository _compatibilityDataRepository =
      getIt<CompatibilityDataRepository>();
  late List<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = List.generate(4, (_) => false);
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
                    setState(() {
                      _isExpanded[index] = !_isExpanded[index];
                    });
                  },
                  children: expansionPanels,
                ),
              ),
              const SizedBox(height: 25),
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
        recData,
      ));
    }

    // Add astrological bonus tip
    var bonusTip = recommendationsData['astrologicalBonusTip'];
    cards.add(_buildCustomExpansionPanel(
      5,
      'Astrological Bonus Tip',
      bonusTip,
    ));

    return cards;
  }

  CustomExpansionPanel _buildCustomExpansionPanel(
    int index,
    String header,
    String details,
  ) {
    return CustomExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return Container(
          color:
              isExpanded ? AppTheme.lemonChiffon : AppTheme.primaryBackground,
          padding: const EdgeInsets.all(16),
          width: double.infinity,
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
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                      children: [
                        TextSpan(
                          text: details.substring(
                              0, details.length > 100 ? 100 : details.length),
                        ),
                        const TextSpan(
                          text: '...Read more',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
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
}
