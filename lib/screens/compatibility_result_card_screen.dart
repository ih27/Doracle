import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../config/dependency_injection.dart';
import '../config/theme.dart';
import '../helpers/purchase_utils.dart';
import '../helpers/show_snackbar.dart';
import '../services/revenuecat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_expansion_panel_list.dart';
import '../widgets/go_deeper_overlay.dart';
import '../widgets/subscribe_success_popup.dart';

class CompatibilityResultCardScreen extends StatefulWidget {
  final String cardId;

  const CompatibilityResultCardScreen({super.key, required this.cardId});

  @override
  _CompatibilityResultCardScreenState createState() =>
      _CompatibilityResultCardScreenState();
}

class _CompatibilityResultCardScreenState
    extends State<CompatibilityResultCardScreen> {
  final RevenueCatService _purchaseService = getIt<RevenueCatService>();
  final UserService _userService = getIt<UserService>();
  late List<bool> _isExpanded;
  Map<String, String> _cachedPrices = {};

  @override
  void initState() {
    super.initState();
    _isExpanded = [false, false, false];
    _fetchPricesIfNeeded();
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
                if (_purchaseService.isEntitled) {
                  setState(() {
                    _isExpanded[index] = !_isExpanded[index];
                  });
                }
              },
              onNonExpandableTap:
                  _purchaseService.isEntitled ? null : _showIAPOverlay,
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
          if (!_purchaseService.isEntitled)
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
      canExpand: _purchaseService.isEntitled,
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
    if (_cachedPrices.isEmpty) {
      try {
        await _purchaseService.ensureInitialized();
        _cachedPrices = await _purchaseService.fetchSubscriptionPrices();
      } catch (e) {
        debugPrint('Error loading prices: $e');
      }
    }
  }

  void _showIAPOverlay() {
    showCustomOverlay<String>(
      context: context,
      heightFactor: 0.55,
      overlayBuilder: (dialogContext, close) => GoDeeperOverlay(
        onClose: close,
        onPurchase: (String subscriptionType) {
          close();
          _handlePurchase(subscriptionType);
        },
        prices: _cachedPrices,
      ),
    );
  }

  Future<void> _handlePurchase(String subscriptionType) async {
    bool success = await _purchase(subscriptionType);

    if (mounted) {
      if (success) {
        showDialog(
          context: context,
          builder: (BuildContext buildContext) {
            return SubscribeSuccessPopup(
              subscriptionType: subscriptionType,
              onContinue: () {
                Navigator.of(buildContext).pop();
              },
            );
          },
        );
      } else {
        showErrorSnackBar(context, 'Purchase failed. Please try again.');
      }
    }
  }

  Future<bool> _purchase(String subscriptionType) async {
    try {
      await _purchaseService.ensureInitialized();
      if (!await _purchaseService.buySubscription(subscriptionType)) {
        return false;
      }
      await _userService.updateSubscriptionHistory(subscriptionType);
      return true;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }
}
