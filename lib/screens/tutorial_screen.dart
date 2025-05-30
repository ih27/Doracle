import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/dependency_injection.dart';
import '../services/unified_analytics_service.dart';
import '../services/revenuecat_service.dart';
import '../helpers/constants.dart';
import '../helpers/string_extensions.dart';
import '../helpers/purchase_utils.dart';
import '../helpers/show_snackbar.dart';
import '../providers/entitlement_provider.dart';
import 'splash_screen.dart';

class TutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  const TutorialScreen({
    super.key,
    required this.onComplete,
    required this.onSignIn,
    required this.onSignUp,
  });

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  late TutorialScreenModel _model;
  final UnifiedAnalyticsService _analytics = getIt<UnifiedAnalyticsService>();
  final RevenueCatService _purchaseService = getIt<RevenueCatService>();
  Map<String, String> _prices = {};
  String _selectedPlan = PurchaseTexts.annual;
  late final List<TutorialPageData> _pageData;

  @override
  void initState() {
    super.initState();
    _model = TutorialScreenModel();
    _loadPrices();
    _initializePages();

    _analytics.logScreenView(screenName: 'tutorial_screen');
  }

  void _initializePages() {
    _pageData = [
      TutorialPageData(
        imagePath: 'assets/images/tuto01.png',
        title: 'Pet-Parent Compatibility Check',
        description:
            'Discover how well you and your pet\'s zodiac signs align, offering insights into your relationship and communication style.',
      ),
      TutorialPageData(
        imagePath: 'assets/images/tuto02.png',
        title: 'Multi-Pet Harmony Forecast',
        description:
            'Planning to add a new pet to your home? Check how well potential new additions will mesh with your current pets based on their astrological profiles.',
      ),
      TutorialPageData(
        imagePath: 'assets/images/tuto03.png',
        title: 'Daily Paw-roscopes',
        description:
            'Start each day with tailored horoscopes for both you and your pets, giving you a playful glimpse into what the stars have in store for your furry friends.',
      ),
      TutorialPageData(
        imagePath: 'assets/images/tuto04.png',
        title: 'The Dog Oracle',
        description:
            'The ultimate source of pet wisdom! Ask anything and receive enlightened answers about you and your pets.',
      ),
      TutorialPageData(
        imagePath: 'assets/images/subscribe_plan.png',
        title: 'Unlock All Features',
        description:
            '-Detailed Compatibility Analysis\n-Unlimited Pet Oracle Questions\n-Personalized Improvement Plans\n-Comprehensive Results History\n-Multi-Pet Harmony Insights\n-Daily Pet & Owner Horoscopes',
      ),
      TutorialPageData(
        imagePath: 'assets/images/subscribe_plan.png',
        title: 'Unlock All Features',
        description:
            'Compatibility insights, unlimited oracles, personalized plans, history tracking, multi-pet harmony, and daily horoscopes!',
        extraContent: (context) => _buildSubscriptionContent(context),
      ),
    ];
  }

  Future<void> _loadPrices() async {
    try {
      await _purchaseService.ensureInitialized();
      final prices = await _purchaseService.fetchSubscriptionPrices();
      if (mounted) {
        setState(() {
          _prices = prices;
        });
      }
    } catch (e) {
      debugPrint('Error loading prices: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.primaryBackground,
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                PageView(
                  controller: _model.pageViewController,
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._pageData.map((data) =>
                        TutorialPage(data: data, onNextPressed: _nextPage)),
                    _buildFinalPage(),
                  ],
                ),
                Align(
                  alignment: const AlignmentDirectional(-0.85, 0.85),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: smooth_page_indicator.SmoothPageIndicator(
                      controller: _model.pageViewController,
                      count: _pageData.length + 1,
                      axisDirection: Axis.horizontal,
                      onDotClicked: (i) async {
                        await _model.pageViewController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                        );
                      },
                      effect: const smooth_page_indicator.ExpandingDotsEffect(
                        expansionFactor: 2,
                        spacing: 8,
                        radius: 16,
                        dotWidth: 16,
                        dotHeight: 4,
                        dotColor: AppTheme.accent1,
                        activeDotColor: AppTheme.secondaryColor,
                        paintStyle: PaintingStyle.fill,
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

  Widget _buildSubscriptionContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildSubscriptionCard(
              context,
              PurchaseTexts.annual,
              _prices[PurchaseTexts.annualPackageId] ??
                  PurchaseTexts.defaultAnnualPrice,
              true,
            ),
            _buildSubscriptionCard(
              context,
              PurchaseTexts.monthly,
              _prices[PurchaseTexts.monthlyPackageId] ??
                  PurchaseTexts.defaultMonthlyPrice,
              false,
            ),
            _buildSubscriptionCard(
              context,
              PurchaseTexts.weekly,
              _prices[PurchaseTexts.weeklyPackageId] ??
                  PurchaseTexts.defaultWeeklyPrice,
              false,
            ),
          ],
        )
            .animate()
            .fade(duration: 600.ms)
            .moveY(begin: 80, end: 0, duration: 600.ms),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security,
                color: Theme.of(context).primaryColor, size: 16),
            const SizedBox(width: 6),
            Text(
              'Secured with App Store. Cancel anytime.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  ),
            ),
          ],
        )
            .animate()
            .fade(duration: 600.ms)
            .moveY(begin: 100, end: 0, duration: 600.ms),
      ],
    );
  }

  Future<void> _handleSubscription(String planType) async {
    try {
      await _purchaseService.ensureInitialized();
      if (await _purchaseService.buySubscription(planType)) {
        // Track subscription with unified analytics
        String? priceString = _prices[planType == PurchaseTexts.annual
            ? PurchaseTexts.annualPackageId
            : planType == PurchaseTexts.monthly
                ? PurchaseTexts.monthlyPackageId
                : PurchaseTexts.weeklyPackageId];

        if (priceString != null) {
          _analytics.logSubscriptionWithPriceString(
              subscriptionId: planType, priceString: priceString);
        }

        if (mounted) {
          // Refresh entitlement state after successful purchase
          Provider.of<EntitlementProvider>(context, listen: false)
              .refreshEntitlementStatus();

          showInfoSnackBar(context, InfoMessages.subscriptionSuccess);
          _nextPage();
        }
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
      if (mounted) {
        showErrorSnackBar(context, InfoMessages.purchaseFailure);
      }
    }
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    String planType,
    String price,
    bool isBestOffer,
  ) {
    return Consumer<EntitlementProvider>(
      builder: (context, entitlementProvider, child) {
        final bool isSubscribed = entitlementProvider.isEntitled;
        final bool isCurrentPlan =
            entitlementProvider.currentSubscriptionPlan == planType;

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
                  _handleSubscription(planType);
                },
          child: Opacity(
            opacity: isSubscribed && !isCurrentPlan ? 0.6 : 1.0,
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
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          PurchaseTexts.bestValueLabel,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${planType.capitalize()}\nPlan',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
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
      },
    );
  }

  void _nextPage() {
    _model.pageViewController.nextPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  Widget _buildFinalPage() {
    return SplashScreen(
      onSignIn: widget.onSignIn,
      onSignUp: widget.onSignUp,
    );
  }
}

class TutorialPageData {
  final String imagePath;
  final String title;
  final String description;
  final Widget Function(BuildContext)? extraContent;

  TutorialPageData({
    required this.imagePath,
    required this.title,
    required this.description,
    this.extraContent,
  });
}

class TutorialPage extends StatelessWidget {
  final TutorialPageData data;
  final VoidCallback onNextPressed;

  const TutorialPage({
    super.key,
    required this.data,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Image.asset(
          data.imagePath,
          width: double.infinity,
          height: 300,
          fit: BoxFit.contain,
          alignment: const Alignment(0, 1),
        ).animate().fade(duration: 600.ms).scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(1.0, 1.0),
            duration: 600.ms),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 24,
                      letterSpacing: 0,
                    ),
              )
                  .animate()
                  .fade(duration: 600.ms)
                  .moveY(begin: 60, end: 0, duration: 600.ms),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  data.description,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        letterSpacing: 0,
                      ),
                )
                    .animate()
                    .fade(duration: 600.ms)
                    .moveY(begin: 80, end: 0, duration: 600.ms),
              ),
              if (data.extraContent != null) data.extraContent!(context),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.navigate_next_rounded,
                        color: AppTheme.secondaryColor,
                        size: 30,
                      ),
                      onPressed: onNextPressed,
                    ).animate().fade(duration: 600.ms).scale(
                        begin: const Offset(0.4, 0.4),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TutorialScreenModel {
  PageController pageViewController = PageController();

  void dispose() {
    pageViewController.dispose();
  }
}
