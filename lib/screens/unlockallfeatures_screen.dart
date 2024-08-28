import 'package:flutter/material.dart';
import '../config/dependency_injection.dart';
import '../helpers/purchase_utils.dart';
import '../services/revenuecat_service.dart';
import '../services/user_service.dart';

class UnlockAllFeaturesScreen extends StatefulWidget {
  final VoidCallback onPurchaseComplete;

  const UnlockAllFeaturesScreen({
    super.key,
    required this.onPurchaseComplete,
  });

  @override
  UnlockAllFeaturesScreenState createState() => UnlockAllFeaturesScreenState();
}

class UnlockAllFeaturesScreenState extends State<UnlockAllFeaturesScreen> {
  final RevenueCatService _purchaseService = getIt<RevenueCatService>();
  final UserService _userService = getIt<UserService>();

  bool _isLoading = false;
  Map<String, String> _prices = {};

  @override
  void initState() {
    super.initState();
    _loadPrices();
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
                _buildSubscribeButton(context),
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
      height: MediaQuery.of(context).size.height * 0.4,
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
        children: [
          _buildSubscriptionCard(
            context,
            'Annual\nPlan',
            convertAnnualToMonthly(_prices['\$rc_annual']) ?? '\$2.49',
            true,
          ),
          _buildSubscriptionCard(
            context,
            'Monthly\nPlan',
            _prices['\$rc_monthly'] ?? '\$2.99',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
      BuildContext context, String title, String price, bool isBestOffer) {
    return Container(
      width: 150,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
        gradient: isBestOffer
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).primaryColor
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
      ),
      child: Column(
        children: [
          if (isBestOffer)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Text(
                'Best Offer',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.white),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Column(
                    children: [
                      Text(
                        price,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '/month',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildSubscribeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        onPressed: () {
          // Implement subscription logic here
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(320, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Subscribe'),
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
