import 'package:doracle/helpers/string_extensions.dart';
import 'package:flutter/material.dart';
import '../config/dependency_injection.dart';
import '../config/theme.dart';
import '../helpers/compatibility_utils.dart';
import '../helpers/purchase_utils.dart';
import '../helpers/show_snackbar.dart';
import '../services/revenuecat_service.dart';
import '../services/user_service.dart';
import '../widgets/subscribe_success_popup.dart';

class UnlockAllFeaturesScreen extends StatefulWidget {
  const UnlockAllFeaturesScreen({
    super.key,
  });

  @override
  UnlockAllFeaturesScreenState createState() => UnlockAllFeaturesScreenState();
}

class UnlockAllFeaturesScreenState extends State<UnlockAllFeaturesScreen> {
  final RevenueCatService _purchaseService = getIt<RevenueCatService>();
  final UserService _userService = getIt<UserService>();

  bool _isLoading = false;
  Map<String, String> _prices = {};
  String _selectedPlan = 'annual';
  bool _isEntitled = false;

  @override
  void initState() {
    super.initState();
    _loadPrices();
    _checkEntitlement();
  }

  void _checkEntitlement() {
    bool isEntitled = _purchaseService.isEntitled;
    setState(() {
      _isEntitled = isEntitled;
    });
  }

  Future<void> _loadPrices() async {
    setState(() => _isLoading = true);
    try {
      await _purchaseService.ensureInitialized();
      _prices = await _purchaseService.fetchSubscriptionPrices();
    } catch (e) {
      debugPrint('Error loading prices: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handlePurchase(String subscriptionType) async {
    if (_isEntitled) return;

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
                navigateToHome(buildContext);
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
      _checkEntitlement();
      return true;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon:
                  Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            forceMaterialTransparency: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeaderImage(),
                _buildTitle(context),
                _buildFeaturesList(context),
                _buildSubscriptionOptions(context),
                _buildSecurityInfo(context),
                _buildSubscribeButton(context, _selectedPlan),
                _buildFooterInfo(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildHeaderImage() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.27,
      child: Image.asset(
        'assets/images/subscribe_plan.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Unlock All Features',
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w900,
          ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        '• Detailed Compatibility Analysis\n'
        '• Unlimited Pet Oracle Questions\n'
        '• Personalized Improvement Plans\n'
        '• Comprehensive Results History\n'
        '• Multi-Pet Harmony Insights\n'
        '• Daily Pet & Owner Horoscopes',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildSubscriptionOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSubscriptionCard(
            context,
            'annual',
            convertAnnualToMonthly(_prices['\$rc_annual']) ?? '\$2.49',
            true,
          ),
          _buildSubscriptionCard(
            context,
            'monthly',
            _prices['\$rc_monthly'] ?? '\$2.99',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
      BuildContext context, String planType, String price, bool isBestOffer) {
    bool isSelected = _selectedPlan == planType;
    double cardWidth = 150;
    double cardHeight = 200;
    double bestOfferHeight = 30;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = planType;
        });
      },
      child: SizedBox(
        width: cardWidth,
        height: isBestOffer ? cardHeight + bestOfferHeight : cardHeight,
        child: Column(
          children: [
            if (isBestOffer)
              Container(
                width: cardWidth,
                height: bestOfferHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).primaryColor
                    ],
                    stops: const [0, 1],
                    begin: const AlignmentDirectional(0, -1),
                    end: const AlignmentDirectional(0, 1),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Best Offer',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppTheme.lemonChiffon, AppTheme.naplesYellow],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isBestOffer ? 0 : 20),
                  topRight: Radius.circular(isBestOffer ? 0 : 20),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                ),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '${planType.capitalize()}\nPlan',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: 22,
                          ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          price,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: AppTheme.success,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '/month',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.security, color: Theme.of(context).primaryColor),
        const SizedBox(width: 10),
        Text(
          'Secured with App Store. Cancel anytime.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context, String subscriptionType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        onPressed: _isEntitled ? null : () => _handlePurchase(subscriptionType),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(320, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: _isEntitled ? Colors.grey : null,
        ),
        child: Text(_isEntitled ? 'Subscribed' : 'Subscribe'),
      ),
    );
  }

  Widget _buildFooterInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          'Subscription is optional and auto-renewable',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFooterLink(context, 'Terms of Service'),
            _buildFooterLink(context, 'Privacy Policy'),
            _buildFooterLink(context, 'Subscription Terms'),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
            decoration: TextDecoration.underline,
          ),
    );
  }

  Widget _buildLoadingOverlay() {
    return _isLoading
        ? Container(
            color: Theme.of(context).primaryColor.withOpacity(0.25),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
