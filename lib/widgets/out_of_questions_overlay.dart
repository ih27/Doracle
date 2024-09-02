import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../helpers/constants.dart';

class OutOfQuestionsOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final Function(int) onPurchase;
  final Map<String, String> prices;

  const OutOfQuestionsOverlay({
    super.key,
    required this.onClose,
    required this.onPurchase,
    required this.prices,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    const containerPadding = 5.0;
    final treatCardWidth = (w * 0.9 - containerPadding * 2) / 3;

    return Material(
      color: Colors.transparent,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: w * 0.95,
        //height: h * 0.5,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(2, 2),
            )
          ],
          gradient: const LinearGradient(
            colors: [AppTheme.primaryBackground, AppTheme.lemonChiffon],
            stops: [0, 1],
            begin: AlignmentDirectional(0, -1),
            end: AlignmentDirectional(0, 1),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildTopSection(context, w, h),
            Stack(
              alignment: const AlignmentDirectional(0, -1),
              children: [
                Padding(
                  padding: const EdgeInsets.all(containerPadding),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTreatCard(
                          context,
                          w,
                          h,
                          treatCardWidth,
                          PurchaseTexts.smallTreat,
                          PurchaseTexts.smallTreatQuestionCount.toString(),
                          prices[PurchaseTexts.smallTreatPackageId] ??
                              PurchaseTexts.discountedSmallTreatPrice,
                          false),
                      _buildTreatCard(
                          context,
                          w,
                          h,
                          treatCardWidth,
                          PurchaseTexts.mediumTreat,
                          PurchaseTexts.mediumTreatQuestionCount.toString(),
                          prices[PurchaseTexts.mediumTreatPackageId] ??
                              PurchaseTexts.discountedMediumTreatPrice,
                          true),
                      _buildTreatCard(
                          context,
                          w,
                          h,
                          treatCardWidth,
                          PurchaseTexts.largeTreat,
                          PurchaseTexts.largeTreatQuestionCount.toString(),
                          prices[PurchaseTexts.largeTreatPackageId] ??
                              PurchaseTexts.discountedLargeTreatPrice,
                          false),
                    ],
                  ),
                ),
                _buildBestValueLabel(context, w, h),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context, double w, double h) {
    return Container(
      width: w * 0.95,
      height: h * 0.23,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: Image.asset('assets/images/paw.png').image,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 15, 15, 5),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: w * 0.1,
                  height: w * 0.1,
                  decoration: const BoxDecoration(),
                ),
                Text(
                  'Oops!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.accent1,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 1,
                      ),
                    ),
                    minimumSize: Size(w * 0.1, w * 0.1),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: w * 0.95,
            height: h * 0.15,
            decoration: const BoxDecoration(),
            alignment: const AlignmentDirectional(0, 0),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                PurchaseTexts.purchaseOverlayDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatCard(
      BuildContext context,
      double w,
      double h,
      double cardWidth,
      String treatSize,
      String questionCount,
      String price,
      bool isMiddle) {
    return Container(
      width: cardWidth,
      height: h * 0.4,
      decoration: BoxDecoration(
        color: isMiddle ? AppTheme.lemonChiffon : AppTheme.primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMiddle ? AppTheme.sandyBrown : AppTheme.accent1,
          width: isMiddle ? 4 : 2,
        ),
        boxShadow: isMiddle
            ? [
                const BoxShadow(
                  blurRadius: 4,
                  color: AppTheme.sandyBrown,
                  offset: Offset(2, 2),
                )
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 20, 5, 5),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '$treatSize\nTreat',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    letterSpacing: 0,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: cardWidth * 0.8,
                height: cardWidth * 0.8,
                decoration: BoxDecoration(
                  color: isMiddle ? AppTheme.success : AppTheme.accent2,
                  shape: BoxShape.circle,
                ),
                alignment: const AlignmentDirectional(0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      questionCount,
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(
                            color: isMiddle ? AppTheme.info : AppTheme.success,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'questions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isMiddle
                                ? AppTheme.alternateColor
                                : AppTheme.primaryColor,
                            letterSpacing: 0,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            AutoSizeText(
              price,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.success,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              minFontSize: 16,
              maxFontSize: 32,
            ),
            ElevatedButton(
              onPressed: () => onPurchase(int.parse(questionCount)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    isMiddle ? AppTheme.secondaryColor : AppTheme.primaryColor,
                minimumSize: Size(cardWidth * 0.7, h * 0.05),
                padding: EdgeInsets.zero,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      letterSpacing: 0,
                    ),
              ),
              child: const Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestValueLabel(BuildContext context, double w, double h) {
    return Material(
      color: Colors.transparent,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: w * 0.25,
        height: h * 0.04,
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: AppTheme.success,
              offset: Offset(0, 2),
            )
          ],
          gradient: const LinearGradient(
            colors: [AppTheme.tomato, AppTheme.sandyBrown],
            stops: [0, 1],
            begin: AlignmentDirectional(0, 1),
            end: AlignmentDirectional(0, -1),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: const AlignmentDirectional(0, 0),
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
    );
  }
}
