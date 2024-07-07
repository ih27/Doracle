import 'package:flutter/material.dart';
import '../theme.dart';

class TreatCard extends StatelessWidget {
  final String treatSize;
  final int questionCount;
  final String originalPrice;
  final String discountedPrice;
  final String description;
  final bool isHighlighted;
  final VoidCallback onTap;

  const TreatCard({
    super.key,
    required this.treatSize,
    required this.questionCount,
    required this.originalPrice,
    required this.discountedPrice,
    required this.description,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: isHighlighted ? AppTheme.lemonChiffon : AppTheme.primaryBackground,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(100),
              topLeft: Radius.circular(20),
              topRight: Radius.circular(100),
            ),
            border: Border.all(
              color: isHighlighted ? AppTheme.sandyBrown : AppTheme.accent1,
              width: 5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$treatSize Treat',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Expanded(
                        child: Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Row(
                        children: [
                          _buildQuestionCountCircle(context),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    originalPrice,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppTheme.error,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: AppTheme.error,
                                    ),
                                  ),
                                  Text(
                                    discountedPrice,
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: AppTheme.success,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (isHighlighted) _buildBestValueLabel(context),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildBuySection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCountCircle(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: isHighlighted ? AppTheme.secondaryColor : AppTheme.accent2,
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$questionCount',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: isHighlighted ? AppTheme.primaryBackground : AppTheme.yaleBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'questions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isHighlighted ? AppTheme.alternateColor : AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestValueLabel(BuildContext context) {
    return Container(
      width: 100,
      height: 25,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.tomato, AppTheme.sandyBrown],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: Text(
        'Best Value',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.primaryBackground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildBuySection(BuildContext context) {
    return Container(
      width: 120,
      height: 200,
      decoration: BoxDecoration(
        color: isHighlighted ? AppTheme.sandyBrown : AppTheme.accent1,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(100),
          topRight: Radius.circular(100),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'BUY',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.yaleBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '$treatSize Treat',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.yaleBlue,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}