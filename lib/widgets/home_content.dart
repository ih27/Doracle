import 'package:flutter/material.dart';
import '../config/theme.dart';

class HomeContent extends StatelessWidget {
  final String welcomeMessage;
  final VoidCallback onContinue;

  const HomeContent({
    super.key,
    required this.welcomeMessage,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              welcomeMessage,
              textAlign: TextAlign.start,
              style: AppTheme.dogTextStyle,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              minimumSize: const Size(0, 40),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
        ),
      ],
    );
  }
}
