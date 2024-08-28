import 'package:flutter/material.dart';
import '../config/theme.dart';

class OracleHomeContent extends StatelessWidget {
  final String welcomeMessage;
  final VoidCallback onContinuePressed;

  const OracleHomeContent({
    super.key,
    required this.welcomeMessage,
    required this.onContinuePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  welcomeMessage,
                  textAlign: TextAlign.center,
                  style: AppTheme.dogTextStyle,
                ),
              ),
            ),
          ),
        ),
        _buildContinueButton(context),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: ElevatedButton(
        onPressed: onContinuePressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          minimumSize: const Size(150, 40), // Set a minimum width and height
          padding: const EdgeInsets.symmetric(horizontal: 24),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Ask Away',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                letterSpacing: 0,
              ),
        ),
      ),
    );
  }
}
