import 'package:flutter/material.dart';
import '../theme.dart';

class PurchaseSuccessPopup extends StatelessWidget {
  final int questionCount;
  final VoidCallback onContinue;

  const PurchaseSuccessPopup({
    super.key,
    required this.questionCount,
    required this.onContinue,
  });

  String _getTreatSize(int questionCount) {
    if (questionCount <= 10) return 'Small';
    if (questionCount <= 30) return 'Medium';
    return 'Large';
  }

  @override
  Widget build(BuildContext context) {
    final treatSize = _getTreatSize(questionCount);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$treatSize Treat',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.success,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 0,
                    ),
                children: [
                  const TextSpan(text: 'Pawsome! You\'ve got '),
                  TextSpan(
                    text: '$questionCount more questions ',
                    style: const TextStyle(
                      color: AppTheme.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: 'to ask Doracle. Time to unleash some new wisdom!',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppTheme.success,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Continue',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      letterSpacing: 0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
