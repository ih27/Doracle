import 'package:auto_size_text/auto_size_text.dart';
import 'package:doracle/helpers/string_extensions.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../helpers/constants.dart';
import '../helpers/purchase_utils.dart';

class GoDeeperOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final Function(String) onPurchase;
  final Map<String, String> prices;

  const GoDeeperOverlay({
    super.key,
    required this.onClose,
    required this.onPurchase,
    required this.prices,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBackground, AppTheme.lemonChiffon],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          _buildSubscriptionOptions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/paw.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              Text(
                PurchaseTexts.subscribeTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.accent1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            PurchaseTexts.subscribeDescription,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSubscriptionCard(
            context,
            PurchaseTexts.annual,
            prices[PurchaseTexts.annualPackageId] ??
                PurchaseTexts.defaultAnnualPrice,
            true,
          ),
          _buildSubscriptionCard(
            context,
            PurchaseTexts.monthly,
            prices[PurchaseTexts.monthlyPackageId] ??
                PurchaseTexts.defaultMonthlyPrice,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
      BuildContext context, String packageId, String price, bool isBestValue) {
    bool isAnnual = packageId == PurchaseTexts.annual;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.42,
          height: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isBestValue
                ? AppTheme.lemonChiffon
                : AppTheme.primaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isBestValue ? AppTheme.sandyBrown : AppTheme.accent1,
              width: isBestValue ? 4 : 2,
            ),
            boxShadow: isBestValue
                ? [
                    const BoxShadow(
                      blurRadius: 4,
                      color: AppTheme.sandyBrown,
                      offset: Offset(2, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${packageId.capitalize()}\nPlan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      letterSpacing: 0,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              Column(
                children: [
                  AutoSizeText(
                    isAnnual ? convertAnnualToMonthly(price)! : price,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppTheme.success,
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    minFontSize: 18,
                  ),
                  Text(
                    '/month',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          letterSpacing: 0,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  if (isAnnual)
                    Text(
                      '($price/year)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                ],
              ),
              ElevatedButton(
                onPressed: () => onPurchase(packageId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBestValue
                      ? AppTheme.secondaryColor
                      : AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Subscribe',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        letterSpacing: 0,
                      ),
                ),
              ),
            ],
          ),
        ),
        if (isBestValue)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 100,
                height: 25,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.tomato, AppTheme.sandyBrown],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4,
                      color: AppTheme.success,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  PurchaseTexts.bestValueLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryBackground,
                        fontSize: 16,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
