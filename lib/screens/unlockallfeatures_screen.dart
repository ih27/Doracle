import 'package:doracle/helpers/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/dependency_injection.dart';
import '../config/theme.dart';
import '../helpers/compatibility_utils.dart';
import '../helpers/constants.dart';
import '../helpers/purchase_utils.dart';
import '../helpers/show_snackbar.dart';
import '../providers/entitlement_provider.dart';
import '../services/revenuecat_service.dart';
import '../services/user_service.dart';
import '../services/unified_analytics_service.dart';
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
  final UnifiedAnalyticsService _analytics = getIt<UnifiedAnalyticsService>();

  bool _isLoading = false;
  Map<String, String> _prices = {};
  String _selectedPlan = PurchaseTexts.annual;

  @override
  void initState() {
    super.initState();
    _loadPrices();

    // Track screen view
    _analytics.logScreenView(screenName: 'subscription_screen');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final entitlementProvider =
          Provider.of<EntitlementProvider>(context, listen: false);
      entitlementProvider.refreshEntitlementStatus();
      _updateSelectedPlan(entitlementProvider.currentSubscriptionPlan);
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

  void _updateSelectedPlan(String? currentPlan) {
    if (currentPlan != null) {
      setState(() {
        _selectedPlan = currentPlan;
      });
    }
  }

  Future<void> _handlePurchase(String subscriptionType) async {
    bool success = await _purchase(subscriptionType);

    if (mounted) {
      if (success) {
        Provider.of<EntitlementProvider>(context, listen: false)
            .refreshEntitlementStatus();
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

      // Track subscription with unified analytics
      String? price = _prices[subscriptionType == PurchaseTexts.annual
          ? PurchaseTexts.annualPackageId
          : subscriptionType == PurchaseTexts.monthly
              ? PurchaseTexts.monthlyPackageId
              : PurchaseTexts.weeklyPackageId];

      if (price != null) {
        _analytics.logSubscriptionWithPriceString(
            subscriptionId: subscriptionType, priceString: price);
      }

      await _userService.updateSubscriptionHistory(subscriptionType);
      return true;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EntitlementProvider>(
      builder: (context, entitlementProvider, child) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: Theme.of(context).primaryColor),
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
                    _buildSubscriptionOptions(context, entitlementProvider),
                    _buildSecurityInfo(context),
                    _buildSubscribeButton(
                        context, entitlementProvider, _selectedPlan),
                    _buildFooterInfo(context, entitlementProvider),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildLoadingOverlay(),
          ],
        );
      },
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
      PurchaseTexts.subscribeTitle,
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
        PurchaseTexts.subscribeFeaturesList,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildSubscriptionOptions(
      BuildContext context, EntitlementProvider entitlementProvider) {
    final currentPlan = entitlementProvider.currentSubscriptionPlan;
    final isSubscribed = entitlementProvider.isEntitled;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSubscriptionCard(
            context,
            PurchaseTexts.annual,
            _prices[PurchaseTexts.annualPackageId] ??
                PurchaseTexts.defaultAnnualPrice,
            true,
            isSubscribed,
            currentPlan == PurchaseTexts.annual,
          ),
          _buildSubscriptionCard(
            context,
            PurchaseTexts.monthly,
            _prices[PurchaseTexts.monthlyPackageId] ??
                PurchaseTexts.defaultMonthlyPrice,
            false,
            isSubscribed,
            currentPlan == PurchaseTexts.monthly,
          ),
          _buildSubscriptionCard(
            context,
            PurchaseTexts.weekly,
            _prices[PurchaseTexts.weeklyPackageId] ??
                PurchaseTexts.defaultWeeklyPrice,
            false,
            isSubscribed,
            currentPlan == PurchaseTexts.weekly,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    String planType,
    String price,
    bool isBestOffer,
    bool isSubscribed,
    bool isCurrentPlan,
  ) {
    // If subscribed, only highlight current plan
    // If not subscribed, only highlight selected plan
    final bool isHighlighted =
        isSubscribed ? isCurrentPlan : _selectedPlan == planType;

    bool isAnnual = planType == PurchaseTexts.annual;
    bool isWeekly = planType == PurchaseTexts.weekly;
    double cardWidth = 110;
    double cardHeight = 160;
    double bestOfferHeight = 24;

    return GestureDetector(
      onTap: isSubscribed
          ? null
          : () {
              setState(() {
                _selectedPlan = planType;
              });
            },
      child: Opacity(
        opacity: isSubscribed && !isCurrentPlan ? 0.6 : 1.0,
        child: Container(
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
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      PurchaseTexts.bestValueLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  gradient: isHighlighted
                      ? const LinearGradient(
                          colors: [
                            AppTheme.lemonChiffon,
                            AppTheme.naplesYellow
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isBestOffer ? 0 : 16),
                    topRight: Radius.circular(isBestOffer ? 0 : 16),
                    bottomLeft: const Radius.circular(16),
                    bottomRight: const Radius.circular(16),
                  ),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${planType.capitalize()}\nPlan',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            price,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: AppTheme.success,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            isAnnual
                                ? '/year'
                                : isWeekly
                                    ? '/week'
                                    : '/month',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 11,
                                ),
                          ),
                          if (isAnnual || isWeekly)
                            Text(
                              '(${isAnnual ? convertAnnualToMonthly(price) : convertWeeklyToMonthly(price)}/month)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
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

  Widget _buildSubscribeButton(BuildContext context,
      EntitlementProvider entitlementProvider, String subscriptionType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        onPressed: entitlementProvider.isEntitled
            ? null
            : () => _handlePurchase(subscriptionType),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(320, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: entitlementProvider.isEntitled ? Colors.grey : null,
        ),
        child:
            Text(entitlementProvider.isEntitled ? 'Subscribed' : 'Subscribe'),
      ),
    );
  }

  Widget _buildFooterInfo(
      BuildContext context, EntitlementProvider entitlementProvider) {
    final currentPlan = entitlementProvider.currentSubscriptionPlan;
    return Column(
      children: [
        Text(
          currentPlan != null
              ? 'Current plan: ${currentPlan.capitalize()} (auto-renewable)'
              : 'Subscription is optional and auto-renewable',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFooterLink(context, PurchaseTexts.termsOfServiceText,
                PurchaseTexts.termsOfServiceUrl),
            _buildFooterLink(context, PurchaseTexts.privacyPolicyText,
                PurchaseTexts.privacyPolicyUrl),
            _buildFooterLink(context, PurchaseTexts.subscriptionTermsText,
                PurchaseTexts.subscriptionTermsUrl),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              decoration: TextDecoration.underline,
            ),
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
