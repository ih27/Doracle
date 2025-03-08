import '../helpers/constants.dart';
import '../services/revenuecat_service.dart';
import 'package:flutter/material.dart';
import '../config/dependency_injection.dart';
import '../helpers/purchase_utils.dart';
import '../helpers/show_snackbar.dart';
import '../services/user_service.dart';
import '../widgets/purchase_success_popup.dart';
import '../widgets/treat_card.dart';
import '../services/unified_analytics_service.dart';

class FeedTheDogScreen extends StatefulWidget {
  final VoidCallback onPurchaseComplete;

  const FeedTheDogScreen({
    super.key,
    required this.onPurchaseComplete,
  });

  @override
  FeedTheDogScreenState createState() => FeedTheDogScreenState();
}

class FeedTheDogScreenState extends State<FeedTheDogScreen> {
  final RevenueCatService _purchaseService = getIt<RevenueCatService>();
  final UserService _userService = getIt<UserService>();
  final UnifiedAnalyticsService _analytics = getIt<UnifiedAnalyticsService>();

  bool _isLoading = false;
  Map<String, String> _prices = {};

  @override
  void initState() {
    super.initState();
    _loadPrices();

    // Track screen view
    _analytics.logScreenView(screenName: 'feedthedog_screen');
  }

  Future<void> _loadPrices() async {
    setState(() => _isLoading = true);
    try {
      await _purchaseService.ensureInitialized();
      _prices = await _purchaseService.fetchPrices();
    } catch (e) {
      debugPrint('Error loading prices: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handlePurchase(int questionCount) async {
    setState(() => _isLoading = true);

    try {
      await _purchaseService.ensureInitialized();

      if (!await _purchaseService.purchaseProduct(questionCount)) {
        throw Exception('Purchase failed');
      }

      // Track purchase with analytics
      String packageId = questionCount == PurchaseTexts.smallTreatQuestionCount
          ? PurchaseTexts.smallTreatPackageId
          : questionCount == PurchaseTexts.mediumTreatQuestionCount
              ? PurchaseTexts.mediumTreatPackageId
              : PurchaseTexts.largeTreatPackageId;

      String? price = _prices[packageId];
      if (price != null) {
        _analytics.logPurchaseWithPriceString(
          priceString: price,
          productIdentifier: packageId,
          parameters: {'question_count': questionCount.toString()},
        );
      }

      await _userService.updatePurchaseHistory(questionCount);
      widget.onPurchaseComplete();

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);

      showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return PurchaseSuccessPopup(
            questionCount: questionCount,
            onContinue: () => Navigator.of(buildContext).pop(),
          );
        },
      );
    } catch (e) {
      debugPrint('Purchase error: $e');
      if (mounted) {
        showErrorSnackBar(context, 'Purchase failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(PurchaseTexts.purchaseTitle),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            forceMaterialTransparency: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: Text(
                  PurchaseTexts.purchaseDescription,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    TreatCard(
                      treatSize: PurchaseTexts.smallTreat,
                      questionCount: PurchaseTexts.smallTreatQuestionCount,
                      originalPrice: convertPrice(
                              _prices[PurchaseTexts.smallTreatPackageId]) ??
                          PurchaseTexts.defaultSmallTreatPrice,
                      discountedPrice:
                          _prices[PurchaseTexts.smallTreatPackageId] ??
                              PurchaseTexts.discountedSmallTreatPrice,
                      description: PurchaseTexts.smallTreatDescription,
                      onTap: () => _handlePurchase(
                          PurchaseTexts.smallTreatQuestionCount),
                    ),
                    TreatCard(
                      treatSize: PurchaseTexts.mediumTreat,
                      questionCount: PurchaseTexts.mediumTreatQuestionCount,
                      originalPrice: convertPrice(
                              _prices[PurchaseTexts.mediumTreatPackageId]) ??
                          PurchaseTexts.defaultMediumTreatPrice,
                      discountedPrice:
                          _prices[PurchaseTexts.mediumTreatPackageId] ??
                              PurchaseTexts.discountedMediumTreatPrice,
                      description: PurchaseTexts.mediumTreatDescription,
                      isHighlighted: true,
                      onTap: () => _handlePurchase(
                          PurchaseTexts.mediumTreatQuestionCount),
                    ),
                    TreatCard(
                      treatSize: PurchaseTexts.largeTreat,
                      questionCount: PurchaseTexts.largeTreatQuestionCount,
                      originalPrice: convertPrice(
                              _prices[PurchaseTexts.largeTreatPackageId]) ??
                          PurchaseTexts.defaultLargeTreatPrice,
                      discountedPrice:
                          _prices[PurchaseTexts.largeTreatPackageId] ??
                              PurchaseTexts.discountedLargeTreatPrice,
                      description: PurchaseTexts.largeTreatDescription,
                      onTap: () => _handlePurchase(
                          PurchaseTexts.largeTreatQuestionCount),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildLoadingOverlay()
      ],
    );
  }
}
