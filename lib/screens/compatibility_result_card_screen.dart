import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/custom_expansion_panel_list.dart';

class CompatibilityResultCardScreen extends StatefulWidget {
  final String cardId;

  const CompatibilityResultCardScreen({super.key, required this.cardId});

  @override
  _CompatibilityResultCardScreenState createState() =>
      _CompatibilityResultCardScreenState();
}

class _CompatibilityResultCardScreenState
    extends State<CompatibilityResultCardScreen> {
  late List<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = [false, false, false];
  }

  @override
  Widget build(BuildContext context) {
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
              children: [
                _buildCustomExpansionPanel(
                  0,
                  'Sun Sign Compatibility',
                  'Aries and Cancer are quite different in their core natures...',
                  'Aries and Cancer are quite different in their core natures. Aries, ruled by Mars, is fiery, direct, and independent, often driven by a desire for action and new experiences. Cancer, ruled by the Moon, is emotional, nurturing, and seeks security. While Aries might sometimes come across as too bold or impatient for Cancer, Cancer\'s caring nature can soften Aries\' rough edges. This pairing can work well if Aries learns to be more sensitive to Cancer\'s emotional needs, and Cancer becomes more assertive in expressing their desires.',
                ),
                _buildCustomExpansionPanel(
                  1,
                  'Moon Sign Compatibility',
                  'If Aries has a Moon in a fire sign (Aries, Leo, Sagittarius), their emotional responses are likely to be quick and intense...',
                  'If Aries has a Moon in a fire sign (Aries, Leo, Sagittarius), their emotional responses are likely to be quick and intense, which might clash with Cancer\'s tendency to retreat into their shell when overwhelmed. On the other hand, if Cancer\'s Moon is in a water sign (Cancer, Scorpio, Pisces), they might feel emotionally safe and nurtured by Aries\' warmth, provided Aries doesn\'t rush them. The key here is emotional understanding and patience; Aries must learn to temper their impulses, while Cancer needs to communicate openly about their feelings.',
                ),
                _buildCustomExpansionPanel(
                  2,
                  'Rising Sign Compatibility',
                  'The Rising sign, or Ascendant, reflects how individuals present themselves to the world....',
                  'The Rising sign, or Ascendant, reflects how individuals present themselves to the world. If Aries has a fire or air Rising sign, they might appear confident, outgoing, and dynamic. If Cancer has a water or earth Rising sign, they might come across as more reserved and grounded. These differences in outward behavior can either create a dynamic, complementary partnership or lead to misunderstandings if they don\'t appreciate each other\'s approach. Aries\' enthusiasm can inspire Cancer to step out of their comfort zone, while Cancer\'s caution can help Aries avoid rash decisions.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
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
                            style: Theme.of(context).textTheme.bodyMedium),
                        Text('In-depth practical compatibility analysis.',
                            style: Theme.of(context).textTheme.bodyMedium),
                        Text(
                            'Comprehensive astrological compatibility breakdown.',
                            style: Theme.of(context).textTheme.bodyMedium),
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
  }

  CustomExpansionPanel _buildCustomExpansionPanel(
      int index, String header, String summary, String details) {
    return CustomExpansionPanel(
      isExpanded: _isExpanded[index],
      headerBuilder: (BuildContext context, bool isExpanded) {
        return Container(
          color:
              isExpanded ? AppTheme.lemonChiffon : AppTheme.primaryBackground,
          padding: const EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width,
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
                minFontSize: 18,
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
    );
  }

  Widget _purchaseButton() {
    return GestureDetector(
      onTap: () => {}, // implement later
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
}
