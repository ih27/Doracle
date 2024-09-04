import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../helpers/string_extensions.dart';

class SubscribeSuccessPopup extends StatelessWidget {
  final String subscriptionType;
  final VoidCallback onContinue;

  const SubscribeSuccessPopup({
    super.key,
    required this.subscriptionType,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
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
              '${subscriptionType.capitalize()} Plan',
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
                children: const [
                  TextSpan(
                    text:
                        'Pawsome news! You\'ve just fetched yourself a subscription!',
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
